@{
  # Version number of this module.
  moduleVersion = '0.3.0.0'

  # ID used to uniquely identify this module
  GUID = '92205aad-768e-4ff3-b448-3f80412a6523'

  # Author of this module
  Author = 'Microsoft Corporation'

  # Company or vendor of this module
  CompanyName = 'Microsoft Corporation'

  # Copyright statement for this module
  Copyright = '(c) 2018 Microsoft Corporation. All rights reserved.'

  # Description of the functionality provided by this module
  Description = 'Module with DSC resources to manage WMI Namespace Security.'

  # Minimum version of the Windows PowerShell engine required by this module
  PowerShellVersion = '5.0'

  # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
  NestedModules = @(
    'DSCClassResources\WmiNamespaceSecurity\WmiNamespaceSecurity.psd1'
  )

  # Functions to export from this module
  FunctionsToExport = @()

  # Cmdlets to export from this module
  CmdletsToExport = @()

  RequiredAssemblies = @()

  <#
    DSC resources that will be export from this module.
    Required for DSC to detect PS class-based resources.
  #>
  DscResourcesToExport = @(
    'WmiNamespaceSecurity'
  )

  # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
  PrivateData = @{

      PSData = @{

          # Tags applied to this module. These help with module discovery in online galleries.
          Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

          # A URL to the license for this module.
          LicenseUri = 'https://github.com/PowerShell/WmiNamespaceSecurityDsc/blob/master/LICENSE'

          # A URL to the main website for this project.
          ProjectUri = 'https://github.com/PowerShell/WmiNamespaceSecurityDsc'

          # A URL to an icon representing this module.
          # IconUri = ''

          # ReleaseNotes of this module
        ReleaseNotes = ''

      } # End of PSData hashtable

  } # End of PrivateData hashtable
  }

















