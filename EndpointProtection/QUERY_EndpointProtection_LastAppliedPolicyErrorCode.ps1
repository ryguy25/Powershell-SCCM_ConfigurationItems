### SCCM Configuration Item QUERY Script

### Setup Event Log Source
if ([System.Diagnostics.EventLog]::SourceExists("SCCM DCM Script") -eq $false) {
    New-EventLog -LogName Application -Source "SCCM DCM Script"
}

### Query the local registry to see if there was an error applying EP policy
Try {

    $lastErrorCode = (Get-Item HKLM:\SOFTWARE\Microsoft\CCM\EPAgent).GetValue("LastAppliedPolicyErrorCode")
    Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Information -EventId 0 `
        -Message "Value in HKLM:\SOFTWARE\Microsoft\CCM\EPAgent:LastAppliedPolicyErrorCode was $lastErrorCode"

}

Catch {

    Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Error -EventId 1 `
        -Message $_.Exception.Message
    $lastErrorCode = -1
}

Write-Output $lastErrorCode