# WmiNamespaceSecurityDsc

This module contains DSC resources to manage WMI Namespace Security.

This project has adopted [this code of conduct](CODE_OF_CONDUCT.md).

This is a reworking of enabling management of WMI Namespace Security using
PowerShell.

>[Steve Lee](https://github.com/SteveL-MSFT) originally created some scripts
>almost 6 years ago.
>Read his articles
>[Scripting WMI Namespace Security (part 1 of 3)](http://blogs.msdn.com/b/wmi/archive/2009/07/20/scripting-wmi-namespace-security-part-1-of-3.aspx),
>[Scripting WMI Namespace Security (part 2 of 3)](http://blogs.msdn.com/b/wmi/archive/2009/07/24/scripting-wmi-namespace-security-part-2-of-3.aspx),
>[Scripting WMI Namespace Security (part 3 of 3)](http://blogs.msdn.com/b/wmi/archive/2009/07/27/scripting-wmi-namespace-security-part-3-of-3.aspx).
>He thought it would be a good opportunity to enable a simpler model for managing
>WMI Namespace Security using DSC (Desired State Configuration). This also
>provided an opportunity to leverage the new PowerShell Classes.

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/jy76xinfr4fgunaj/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/WmiNamespaceSecurityDsc/branch/master)
[![codecov](https://codecov.io/gh/PowerShell/WmiNamespaceSecurityDsc/branch/master/graph/badge.svg)](https://codecov.io/gh/PowerShell/WmiNamespaceSecurityDsc/branch/master)

This is the branch containing the latest release -
no contributions should be made directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/jy76xinfr4fgunaj/branch/dev?svg=true)](https://ci.appveyor.com/project/PowerShell/WmiNamespaceSecurityDsc/branch/dev)
[![codecov](https://codecov.io/gh/PowerShell/WmiNamespaceSecurityDsc/branch/dev/graph/badge.svg)](https://codecov.io/gh/PowerShell/WmiNamespaceSecurityDsc/branch/dev)

This is the development branch
to which contributions should be proposed by contributors as pull requests.
This development branch will periodically be merged to the master branch,
and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).

## Installation

To manually install the module,
download the source code and unzip the contents
to the '$env:ProgramFiles\WindowsPowerShell\Modules' folder

To install from the PowerShell gallery using PowerShellGet (in PowerShell 5.0)
run the following command:

```powershell
Find-Module -Name WmiNamespaceSecurityDsc -Repository PSGallery | Install-Module
```

To confirm installation, run the below command and ensure you see the SQL Server
DSC resources available:

```powershell
Get-DscResource -Module WmiNamespaceSecurityDsc
```

## Requirements

The minimum Windows Management Framework (PowerShell) version required is 5.0
or higher, which ships with Windows 10 or Windows Server 2016,
but can also be installed on Windows 7 SP1, Windows 8.1,
Windows Server 2008 R2 SP1, Windows Server 2012 and Windows Server 2012 R2.

## Examples

You can review the [Examples](/Examples) directory in the WmiNamespaceSecurityDsc
repository for some general use scenarios for all of the resources that are in the
resource module.

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

* [**WmiNamespaceSecurity**](#wminamespacesecurity)
  resource to ensure an availability group is present or absent.

### WmiNamespaceSecurity

This resource is used to create, remove, and update an Always On Availability Group.
It will also manage the Availability Group replica on the specified node.

#### Parameters

* **`[String]` Path** _(Key)_: *No description yet.*
* **`[String]` Principal** _(Key)_: *No description yet.*
* **`[String]` AccessType** _(Key)_: *No description yet.*
* **`[String]` Ensure** _(Write)_: Specifies if the availability group should be
  present or absent. Default is Present. { *Present* | Absent }
* **`[String[]]` Permission** _(Write)_: *No description yet.*
  { Enable | MethodExecute | FullWrite | PartialWrite | ProviderWrite |
  RemoteAccess | Subscribe | Publish | ReadSecurity | WriteSecurity }
* **`[String]` AppliesTo** _(Write)_: *No description yet.*
  Default is 'Self'. { *Self* | Children }

#### Read-Only Properties from Get-TargetResource

* **`[Boolean]` Inherited** _(Read)_: *No description yet.*

#### Examples

* [Add permission for two accounts to WMI namespace](/Examples/Resources/WmiNamespaceSecurity/1-AddPermissionToNamespace.ps1)
* [Remove two accounts from WMI namespace](/Examples/Resources/WmiNamespaceSecurity/2-RemovePermissionFromNamespace.ps1)
* [Add permission to WMI namespace](/Examples/Resources/WmiNamespaceSecurity/3-WmiNamespaceSecurity_AddPermissionToWmiNamespaceConfig.ps1)
  *(Published to PowerShell Gallery)*
* [Remove account from WMI namespace](/Examples/Resources/WmiNamespaceSecurity/4-WmiNamespaceSecurity_RemovePermissionFromWmiNamespaceConfig.ps1)
  *(Published to PowerShell Gallery)*
