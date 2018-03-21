$isDefenderServiceRunning = $false

$serviceStatus = Get-Service -Name WinDefend

if( $serviceStatus -eq 'Running') {

    $isDefenderServiceRunning = $true

}

return $isDefenderServiceRunning