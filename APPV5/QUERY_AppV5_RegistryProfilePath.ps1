### Setup Event Log Source (if not already present)
if ([System.Diagnostics.EventLog]::SourceExists("SCCM DCM Script") -eq $false) {
    New-EventLog -LogName Application -Source "SCCM DCM Script"
}

### Bool value we'll be returning
$CorrectAppVProfilePathSet = $true

### The registry value we're expecting to see
$APPV_PROFILE_PATH = "%USERPROFILE%\AppData\Local\Microsoft\AppV\Client\VFS"

### The registry key we're looking at
$keyPath = "HKLM:\SOFTWARE\Microsoft\AppV\Client\Virtualization\LocalVFSSecuredUsers"

Try {

    $regKey = Get-Item $keyPath

    $propertyValues = $regKey.GetValueNames()

    foreach ($property in $propertyValues) {

        $regValue = $regKey.GetValue($property)
  
        if ( $regValue -ne $APPV_PROFILE_PATH ) {
    
            $CorrectAppVProfilePathSet = $false
            Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Information -EventId 0 `
                -Message "Value in $keyPath`:$property was $regValue"

        }

    }

}

Catch {

    ### If something went wrong
    Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Error -EventId 1 `
        -Message $_.Exception.Message

}

return $CorrectAppVProfilePathSet