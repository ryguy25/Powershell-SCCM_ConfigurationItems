#REMEDIATE_EndpointProtection_LastAppliedPolicyErrorCode

### Setup Event Log Source
if ([System.Diagnostics.EventLog]::SourceExists("SCCM DCM Script") -eq $false) {
    New-EventLog -LogName Application -Source "SCCM DCM Script"
}

Try {
    
    ### Get error value from registry    
    $errorCode = (Get-Item HKLM:\SOFTWARE\Microsoft\CCM\EPAgent).GetValue("LastAppliedPolicyErrorCode")

    ### Using a switch statement here to leave room for possible expansion to remediate other EP errors        
    switch ($errorCode) {

        ### Error code 2147500037 = "Failed to open the local machine Group Policy"
        ### Error code -2147467529 (appears to be what is returned via powershell)
        
        ### Error code 2147942413 = "Failed to open the local machine Group Policy"
        ### Error code -2147024883 (appears to be what is returned vai powershell)
        { ( $_ -eq 2147500037 ) -or ( $_ -eq -2147467259 ) -or ( $_ -eq 2147942413 ) -or ( $_ -eq -2147024883 ) } {
        
            Remove-Item -Path "$env:windir\System32\GroupPolicy\Machine\Registry.pol" -Force -Confirm:$false
            Remove-Item -Path "$env:ALLUSERSPROFILE\Microsoft\Group Policy\History" -Recurse -Force -Confirm:$false
            Invoke-Command -ScriptBlock { gpupdate /force }
            Restart-Service -Name CcmExec -Force -Confirm:$false
            Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Information -EventId 0 `
                -Message "Successfully deleted %WINDIR%\System32\GroupPolicy, ran gpupdate, and restarted CcmExec service"

        }
        
        default {

            Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Warning -EventId 999 `
                -Message "Error Code $errorCode not detected in the remediation script switch statement.  This is the default case"

        }
    }

}

Catch {

        Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Error -EventId 1 `
            -Message $_.Exception.Message

}
