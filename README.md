# WmiNamespaceSecurity
DSC Resource to manage WMI Namespace Security

This is a reworking of enabling management of WMI Namespace Security using PowerShell.  I originally created some scripts almost 6 years ago that I blogged here:

http://blogs.msdn.com/b/wmi/archive/2009/07/20/scripting-wmi-namespace-security-part-1-of-3.aspx
http://blogs.msdn.com/b/wmi/archive/2009/07/24/scripting-wmi-namespace-security-part-2-of-3.aspx
http://blogs.msdn.com/b/wmi/archive/2009/07/27/scripting-wmi-namespace-security-part-3-of-3.aspx

I thought it would be a good opportunity to enable a simpler model for managing WMI Namespace Security using DSC (Desired State Configuration).  This also
provided an opportunity to leverage the new PowerShell Classes.

Using DSC, you can just write a configuration document such as this:

```powershell
    configuration Sample {

        WMINamespaceSecurity Jason {
            Path = "root/cimv2"
            Principal = "Jason"
            AppliesTo = "Self"
            AccessType = "Allow"
            Permission = "Enable", "MethodExecute", "ProviderWrite"
            Ensure = "Present"
        }

        WMINamespaceSecurity Steve {
            Path = "root/cimv2"
            Principal = "Contoso\Steve"
            AppliesTo = "Children"
            AccessType = "Deny"
            Permission = "Enable", "MethodExecute", "ProviderWrite", "RemoteAccess"
            Ensure = "Present"
        }

    }
```

Save this as a .ps1 file and "dot source" it to make the configuration available in your current scope:

```powershell
	. .\sample.ps1
```

Execute the configuration function:

```powershell
	Sample -OutputPath c:\dsc
```

Now, you can use DSC to deploy the configuration:

```powershell
	Start-DSCConfiguration -Path c:\dsc -Wait -Force
```