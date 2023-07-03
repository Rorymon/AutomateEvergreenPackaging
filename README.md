# AutomateEvergreenPackaging
This is my first draft of a script that leverages the Evergreen PowerShell module and Cloudpager module to automatically package and patch applications using Numecent Cloudpaging Studio for packaging and Cloudpager for deployment.

<b>Setting Up Evergreen Packaging Machine</b>

I have only tested the script on Windows 10 Enterprise. It should work on a machine that is domain joined or non-domain joined. Typically, the preference for pacakging VMs is that they should be non-domain joined to avoid unncessary noise polluting packages. 

![image](https://github.com/Rorymon/AutomateEvergreenPackaging/assets/7652987/4697b8ec-1fa8-4c41-94b9-54004b3549d8)

On your Windows 10 VM, install Cloudpaging Studio. This will be used for packaging the applications and patches into application containers. You can find the latest version of Studio on the Numecent customer support portal.

In order to download applications found in the Evergreen PowerShell and upload completed packages using this script, you should launch the default browser on your machine at least once before taking your snapshot. If Internet Explorer is still on the VM, you should launch this once too.

![image](https://github.com/Rorymon/AutomateEvergreenPackaging/assets/7652987/7d2d2610-da11-43c8-bc29-cf161776c671)

To use the script, you will need to get the Cloudpager PowerShell module from Numecent and you will need to contact support to retrieve your tenant's unique API key. To ensure you can use the PowerShell module in the script as needed, I recommend placing the module in your Modules directory on your VM e.g. C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Cloudpager.

![image](https://github.com/Rorymon/AutomateEvergreenPackaging/assets/7652987/1c52585e-4af7-4d55-8af5-8ec9e9b89591)

Next step, run the SetupScript.ps1 that is on my GitHub repository, this will create the directories for your packaging projects and it will download the relevant scripts.

![image](https://github.com/Rorymon/AutomateEvergreenPackaging/assets/7652987/678dedf0-cfa5-4c0f-8749-779015af7eb7)

Next, install the Evergreen PowerShell Module e.g. Install-Module Evergreen

![image](https://github.com/Rorymon/AutomateEvergreenPackaging/assets/7652987/70fffbef-3251-4408-aee2-ff9e8aea1c7c)

You should I recommend following Numecent's guidance on prepping your packaging VM. https://github.com/numecent using the prep script on the Numecent github repo. 

![image](https://github.com/Rorymon/AutomateEvergreenPackaging/assets/7652987/775950de-9b34-4496-b230-d36e76a968d9)

With the pre-requisites all now on your VM, you should open the main script to populate some of the variables that are unique to you.

![image](https://github.com/Rorymon/AutomateEvergreenPackaging/assets/7652987/e9c89ee9-f60b-458b-b605-a63b13ff8a66)

You will need to input your API Key and you can optionally step through the script, uncomment some of the optional sections and put in other variables such as your OpenAI API key (if you have one) and a Teams Channel Webhook URI.

You will also require the Evergreen PowerShell Module which is a public community module used to retrieving application data from vendors such as Application Version and Download URIs. You can install this with Install-Module Evergreen.

![image](https://github.com/Rorymon/AutomateEvergreenPackaging/assets/7652987/4854f523-abff-4979-9561-160a4c138310)

