# AutomateEvergreenPackaging
This is my first draft of a script that leverages the Evergreen PowerShell module and Cloudpager module to automatically package and patch applications

To use the script, you will first need to get the Cloudpager PowerShell module from Numecent and the Cloudpaging Studio. I recommend following Numecent's guidance on prepping your packaging VM. https://github.com/numecent

You will also require the Evergreen PowerShell Module which is a public community module used to retrieving application data from vendors such as Application Version and Download URIs. You can install this with Install-Module Evergreen.

In order to download applications found in the Evergreen PowerShell and upload completed packages using this script, you should launch the default browser on your machine at least once before taking your snapshot.

![image](https://github.com/Rorymon/AutomateEvergreenPackaging/assets/7652987/4854f523-abff-4979-9561-160a4c138310)

I recommend creating a folder structure similar to the above. Store this PowerShell script in the Scripts directory along with other accompanying scripts such as the studio-nip.ps1 and CreateJSON.ps1 scripts as found at https://github.com/numecent. I also place a Send-TeamsMessage.ps1 here to send a notification when the script completes but this optional.
