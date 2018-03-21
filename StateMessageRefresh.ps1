### Short script to refresh state messaging on workstations

### Create COM Object and call RefreshServerComplianceState method
$sccmUpdatesStore = New-Object -ComObject Microsoft.CCM.UpdatesStore
$sccmUpdatesStore.RefreshServerComplianceState()

### Cleanup COM Object and dispose of variable
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($sccmUpdatesStore)
Remove-Variable sccmUpdatesStore

Write-EventLog -LogName Application -Source "Configuration Manager Agent" -EntryType Information -EventId 2000 `
            -Message "RefreshServerComplianceState Method was triggered."