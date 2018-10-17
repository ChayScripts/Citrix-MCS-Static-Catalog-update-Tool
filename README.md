# Citrix MCS Static Machine Catalog update Tool

Tool to update MCS static machine catalogs.

##Motivation

Having powershell knowledge is beneficial but not everyone in citrix team knows Posh. So, there may be a dependency for team members who knows scripting/powershell. This tool eliminates such gaps in the team. With this tool anyone can update static machine catalogs.

### Description

Updates your MCS Static(or MCS dynamic) machine catalogs. This tool also works for MCS dynamic VDI catalogs, but citrix already has a GUI option to update MCS dynamic VDI catalogs.

### Prerequisites

* [VMware powercli](https://my.vmware.com/web/vmware/details?downloadGroup=PCLI650R1&productId=614) and Citrix powershell modules are required on the machine you run this tool from.
* Should have permissions on vmware (to read,create and delete snapshots) and citrix (machine catalog administrator)

### Installing

No installation required. This is standalone Tool. 

### Usage

When all powershell modules are installed, Run this tool and Enter citrix server name, machine catalog name, vcenter server name and hit update catalog. Optionally, it also displays the existing snapshot details for machine catalog when you use “Get Existing snapshot details” button.

### How does this tool work

This tool will:

* Remove all existing (old) snapshots from the master image.
* Create new snapshot with today's date.
* Update machine catalog with this new snapshot.
* Display output if successful or failed.

### Quick look at the tool

![Alt Text](https://raw.githubusercontent.com/TechScripts/Citrix-MCS-Static-Catalog-update-Tool/master/Catalog%20Update%20Tool%20Image.PNG)

### Who can use

Preferably Citrix Team/Admins who are responsible for catalog updates.

### Built With

* [PowerShell](https://en.wikipedia.org/wiki/PowerShell) - Powershell
* [XML](https://en.wikipedia.org/wiki/XML) - Used to generate GUI
* [PS2EXE-GUI](https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-e7cb69d5) - Used to convert script to exe

### Authors

* **Tech Guy** - [TechScripts](https://github.com/TechScripts)

### Contributing

Please follow [github flow](https://guides.github.com/introduction/flow/index.html) for contributing.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
