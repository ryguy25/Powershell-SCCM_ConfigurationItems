### Setup Event Log Source
if ([System.Diagnostics.EventLog]::SourceExists("SCCM DCM Script") -eq $false) {
    New-EventLog -LogName Application -Source "SCCM DCM Script"
}

### Reference to CCM_ClientUXSettings WMI Class, so we can access the "SetAutoInstallRequiredSoftwaretoNonBusinessHours" Method
###   See:  https://msdn.microsoft.com/en-us/library/jj902779.aspx
$cmClientUserSettings = [WmiClass]"\\.\ROOT\ccm\ClientSDK:CCM_ClientUXSettings"

Try {
    $result = $cmClientUserSettings.SetAutoInstallRequiredSoftwaretoNonBusinessHours($true)

    if($result.ReturnValue -eq 0) {
        Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Information -EventId 1 `
            -Message "Successfully set AutoInstall setting"
    }
    else{
        Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Error -EventId 0 `
            -Message "Unable to set AutoInstall setting.  Returned value was: $($result.ReturnValue)"
    }
}
Catch {
    "SET_WorkstationAutoInstallUpdates.ps1 script failed with the following exception: " + $_.Exception.Message
}