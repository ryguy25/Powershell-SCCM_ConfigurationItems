### Declare boolean variable that will be returned to SCCM
$boolCompliant = $true

### Query all enabled "Ethernet" devices
$nics = Get-WmiObject Win32_NetworkAdapter -Filter "netenabled = 'true'" | Where-Object {$_.AdapterType -match "Ethernet"}

foreach ($dev in $nics) {

    ### We need the PNPDeviceID 
    $devID = $dev.PNPDeviceID
        
    $devWakeEnable = Get-WmiObject MSPower_DeviceWakeEnable -Namespace root\wmi |
        Where-Object { $_.InstanceName -match [regex]::Escape($devID)}

    ### Make sure $devWakeEnable is not $null.
    if ($devWakeEnable) {

        ### WOL is not enabled if the "Enable" property is not set to $true
        if($devWakeEnable.Enable -eq $false) {
            $boolCompliant = $false
        }

    }

}

### If all enabled network adapters have WOL enabled, this will return $true.  Otherwise, it will return $false
return $boolCompliant