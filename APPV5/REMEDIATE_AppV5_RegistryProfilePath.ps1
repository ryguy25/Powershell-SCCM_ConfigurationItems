### Setup Event Log Source (if not already present)
if ([System.Diagnostics.EventLog]::SourceExists("SCCM DCM Script") -eq $false) {
    New-EventLog -LogName Application -Source "SCCM DCM Script"
}

### Expected value for registry property
$APPV_PROFILE_PATH = "%USERPROFILE%\AppData\Local\Microsoft\AppV\Client\VFS"

### Path to registry key we'll be looking at
$keyPath = "HKLM:\SOFTWARE\Microsoft\AppV\Client\Virtualization\LocalVFSSecuredUsers"

Try {

    $regKey = Get-Item $keyPath

    $propertyValues = $regKey.GetValueNames()

    foreach ($property in $propertyValues) {

        $regValue = $regKey.GetValue($property)
  
        if ( $regValue -ne $APPV_PROFILE_PATH ) {
            
            $result = New-ItemProperty -Path $keyPath -Name $property -Value $APPV_PROFILE_PATH -Force
                        
            Write-EventLog -LogName Application -Source "SCCM DCM SCript" -EntryType Information -EventId 0 `
                -Message "Changed value of $keyPath`:$property to $APPV_PROFILE_PATH"
        }

    }

}

Catch {

    Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Error -EventId 1 `
        -Message $_.Exception.Message

}