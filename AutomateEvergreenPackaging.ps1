<#
.SYNOPSIS
    Auto-package Applications for Cloudpager.
.DESCRIPTION
    This script combines the Evergreen Module, Nevergreen Module and Numecent Auto-package feature to automate application packaging of the latest version of public consumer versions of applications
.PARAMETER AppName
    Name of Application as found in the Evergreen or Nevergreen Find- functions.
.PARAMETER Publisher
    Name of the application's manufacturer.
.PARAMETER Sourcepackagetype
    Define the type of package you wish to auto-package e.g. msi, exe or msix. Other formats are not supported at this time.
.PARAMETER Sourcechannel
    If you wish to define a certain channel such as a stable channel, dev, beta etc. you can define with this parameter.
.PARAMETER Sourceplatform
    Some applications have different supported platforms such as a specific VDI version, if applicable this can be defined.
.PARAMETER Sourcelanguage
    Some applications listed in the Evergreen module have multiple language e.g. Adobe Acrobat Reader DC. In this case, you can select the lanugage that applies.
.PARAMETER image_file_path
    Provide the full path to an image for the application, preferably 512 x 512 in size.
.PARAMETER Arguments
    Passing install arguments for a silent install may be required for an exe installer. This is not required for msi or msix package types.
.PARAMETER CommandLine
    The CommandLine must be set to the full path of the main executable for the application.
.PARAMETER WorkdpodID
    If you wish to automatically publish the application to a Cloudpager Workdpod, pass the WorkpodID here e.g. You may have an early adopters Workpod for UAT.
.PARAMETER Description
    If you would like to set a description for the application, do this here.
.REQUIRES PowerShell Version 5.0, Cloudpager and Evergreen PowerShell modules are required, the PowerShellAI module is optional. You will require this module if you wish to integrate with the OpenAI
    API. You must have Cloudpaging Studio on the packaging VM along with Numecent's CreateJson.ps1 and studio-nip.ps1. You should run the CloudpagingStudio-prep.ps1 on your packaging VM before taking a snapshot. 
.EXAMPLE
    >AutomateEvergreenPackaging.ps1 -AppName "GoogleChrome" -publisher "Google" -sourcepackagetype "msi" -sourcechannel "stable" -image_file_path "\\ImageServer\Images\Chrome.png" -CommandLine "C:\Program Files\Google\Chrome\Application\chrome.exe" -WorkpodID "<id>" -Description "Google Chrome is the world's most popular web browser."
    >AutomateEvergreenPackaging.ps1 -AppName "NotepadPlusPlus" -publisher "Don Ho" -sourcepackagetype "exe" -sourceplatform "Windows" -image_file_path "\\ImageServer\Images\NotepadPlusPlus.png" -Arguments " /S" -CommandLine "C:\Program Files\Notepad++\notepad++.exe" -WorkpodID "<id>"
#>

Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$AppName,

   [Parameter(Mandatory=$True)]
   [string]$Publisher,

   [Parameter(Mandatory=$True)]
   [string]$Sourcepackagetype,

   [Parameter(Mandatory=$False)]
   [string]$Sourcechannel,

   [Parameter(Mandatory=$False)]
   [string]$Sourceplatform,

   [Parameter(Mandatory=$False)]
   [string]$Sourcelanguage,
   
   [Parameter(Mandatory=$True)]
   [string]$image_file_path,

   [Parameter(Mandatory=$False)]
   [string]$Arguments,

   [Parameter(Mandatory=$True)]
   [string]$CommandLine,

   [Parameter(Mandatory=$False)]
   [string]$WorkpodID,

   [Parameter(Mandatory=$True)]
   [string]$Description
)

#Enter values for these variables before using script
$skey = "<CloudpagerAPIKey>"

#Remove comment for the line below and line 174 to send a Teams Notification when complete.
#TeamsURI = "Teams Channel URI"

#Remove comment for the line below and line 174 to send a Teams Notification when complete and enter value with URL to your Cloudpager Apps Dashboard
#$AppsDashboardURL = '<URL to Apps Dashboard>'

#Remove the comments for the next 2 lines and add OpenAI API Key to use Open AI API as part of the script
#$gptkey = ConvertTo-SecureString "<OpenAIAPIKey>" -AsPlainText -Force
#Set-OpenAIKey -key $gptKey

Try
{
    # Try something that could cause an error
    Find-EvergreenApp -Name $AppName | Select -ExpandProperty Application | Sort-Object { [System.Math]::Abs([System.String]::Compare($_, $AppName)) } | Select-Object -First 1
}
Catch
{
    # Catch any error
    Write-Host "An error has occurred retrieving data for $AppName from the Evergreen PowerShell Module. Ensure the module is loaded, if errors continue try to run a query manually using Find-EvergreenApp -Name $AppName"
}

$FriendlyName = Find-EvergreenApp -Name $AppName | Select -ExpandProperty Application | Sort-Object { [System.Math]::Abs([System.String]::Compare($_, $AppName)) } | Select-Object -First 1

#Remove comment for the line below and change Publisher parameter to Mandatory=$False to let OpenAI API populate the Publisher for you.
#$Publisher = ai "What vendor makes $FriendlyName? Just return the short name, no other text and no period." | Out-String

Try
{
    # Try something that could cause an error
    Get-CloudpagerApplication -SubscriptionKey $skey | Where-Object{$_.Name -like $FriendlyName} | Select -ExpandProperty AppVersion
}
Catch
{
    # Catch any error
    Write-Host "An error has occurred retrieving data for $FriendlyName from the Cloudpager PowerShell Module. Ensure the module is loaded, if errors continue try to run a query manually using Get-CloudpagerApplication -SubscriptionKey $skey -Name $FriendlyName with double quotes around the app name."
}

$Curversion = Get-CloudpagerApplication -SubscriptionKey $skey | Where-Object{$_.Name -like $FriendlyName} | Select -ExpandProperty AppVersion

$AppCheck = Get-EvergreenApp -Name "$AppName"

if ($AppCheck.Count -eq 1) {
    $DownloadURL = Get-EvergreenApp -Name $AppName | Select -ExpandProperty URI
    $LatestVersion = Get-EvergreenApp -Name $AppName | Select -ExpandProperty Version
}
else
{

$BaseTest = Get-EvergreenApp -Name $AppName

$LatestVersion = Get-EvergreenApp -Name $AppName | Where-Object { if (!$_.Architecture -or $_.Architecture -eq "x64") {$true} else {$false} } | Where-Object { if (!$_.Channel -or $_.Channel -eq $sourcechannel) {$true} else {$false} } | Where-Object { if (!$_.Type -or $_.Type -eq $sourcepackagetype) {$true} else {$false} } | Where-Object { if (!$_.Platform -or $_.Platform -eq $sourceplatform) {$true} else {$false} } | Where-Object { if (!$_.Language -or $_.Language -eq $sourcelanguage) {$true} else {$false} } | Select -ExpandProperty Version | Select-Object -First 1
$DownloadURL = Get-EvergreenApp -Name $AppName | Where-Object { if (!$_.Architecture -or $_.Architecture -eq "x64") {$true} else {$false} } | Where-Object { if (!$_.Channel -or $_.Channel -eq $sourcechannel) {$true} else {$false} } | Where-Object { if (!$_.Type -or $_.Type -eq $sourcepackagetype) {$true} else {$false} } | Where-Object { if (!$_.Platform -or $_.Platform -eq $sourceplatform) {$true} else {$false} } | Where-Object { if (!$_.Language -or $_.Language -eq $sourcelanguage) {$true} else {$false} } | Select -ExpandProperty URI | Select-Object -First 1
}

$ProjectFolder = "C:\NIP_Software\$AppName"

$DownloadFilePath = "C:\NIP_Software\Auto\Latest$AppName.$sourcepackagetype"

If($LatestVersion -ne $Curversion -or $Curversion -eq $null){

Write-Output "New version detected. Now auto-packaging!"

If(!(test-path $ProjectFolder))
{
      New-Item -ItemType Directory -Force -Path $ProjectFolder
      New-Item -ItemType Directory -Force -Path "$ProjectFolder\Source"
      New-Item -ItemType Directory -Force -Path "$ProjectFolder\Output"
}

$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($DownloadURL, $DownloadFilePath)

#Invoke-WebRequest -Uri $DownloadURL -OutFile $DownloadFilePath

If($sourcepackagetype -eq "msix")
{
$PackageFile = Get-ChildItem -Path "C:\NIP_Software\Auto" -Filter *.msix | ForEach-Object{$_.FullName}
Add-CloudpagerApplication -SubscriptionKey $skey -Filepath $PackageFile -Name $FriendlyName -AppVersion $LatestVersion -Publisher $publisher -ImagePath $image_file_path -Description $Description -PublishComment "Uploaded using API" -Force 
If($WorkpodID){
Set-CloudpagerWorkpod -Subscriptionkey $skey -WorkpodID $WorkpodID -Applications "$FriendlyName" -PublishComment "Added $FriendlyName $LatestVersion" -Confirm -Force
}

}
else
{

#Remove comment for the line below and change Description parameter to let OpenAI API populate the Publisher for you.
#$Description = ai "What is $Publisher $AppName in 30 words or less." | Out-String

.\CreateJson.ps1 -Filepath $DownloadFilePath -Description $Description -Name $FriendlyName -Arguments $Arguments -StudioCommandLine $CommandLine -outputfolder "$ProjectFolder\Output"

$config_file_path = Get-ChildItem -Path "C:\NIP_Software\Auto" -Filter *.json | ForEach-Object{$_.FullName}

.\studio-nip.ps1 -config_file_path $config_file_path

$PackageFile = Get-ChildItem -Path "$ProjectFolder\Output" -Filter *.stp | ForEach-Object{$_.FullName}

Add-CloudpagerApplication -SubscriptionKey $skey -Filepath $PackageFile -Name $FriendlyName -AppVersion $LatestVersion -Publisher $publisher -ImagePath $image_file_path -Description $Description -PublishComment "Uploaded using API" -Force 

Write-Output "$AppName $LatestVersion is now available in Cloudpager!"

#Remove comment for the line below to send a Teams Notification.
#.\SendTeamsMessage.ps1 -WebhookUri $TeamsURI -Title 'App Update' -Message "$AppName $LatestVersion is now available in Cloudpager!" -Proxy 'DoNotUse' -ButtonText 'View' -ButtonURI $AppsDashboardURL 


If($WorkpodID){
Set-CloudpagerWorkpod -Subscriptionkey $skey -WorkpodID $WorkpodID -Applications "$FriendlyName" -PublishComment "Added $FriendlyName $LatestVersion" -Confirm -Force
}
}
}
else
{
Write-Output "Latest version of $AppName is already published in Cloudpager"
}
