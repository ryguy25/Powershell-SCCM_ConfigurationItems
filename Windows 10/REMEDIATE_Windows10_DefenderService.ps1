### Setup Event Log Source
if ([System.Diagnostics.EventLog]::SourceExists("SCCM DCM Script") -eq $false) {
    New-EventLog -LogName Application -Source "SCCM DCM Script"
}

Try {
    
    $regKey = Get-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'
    
    if ( $regKey.Property.Contains("DisableAntiSpyware") ) {
    
        Remove-ItemProperty -Name "DisableAntiSpyware" -Path $regKey.PSPath

    }

    Start-Service -Name WinDefend

}

Catch {

    Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Error -EventId 0 `
        -Message $_.Exception.Message

}