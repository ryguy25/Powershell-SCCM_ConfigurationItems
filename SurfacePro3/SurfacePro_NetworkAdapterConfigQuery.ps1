#Property names for the registry keys we want to query
$PROP_WakeOnMagicPacket = "*WakeOnMagicPacket"
$PROP_EnergyEfficientEthernet = "EEE"
$PROP_SelectiveSuspend = "*SelectiveSuspend"

#Boolean value
$BOOL_WakeOnMagicPacket = $false
$BOOL_EnergyEfficientEthernet = $false
$BOOL_SelectiveSuspend = $false

#This is the location in HKEY_LOCAL_MACHINE that stores the information about Network adapters
$keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"
$networkRegKey = Get-Item $keyPath

#We only want the subkeys that are #### (i.e. 0001, 0002, etc...) as they correspond to the actual network adapters
$subKeys = $networkRegKey.GetSubKeyNames() | Where-Object {$_ -match "\d\d\d\d"}

#Iterate through each network adapter subkey
foreach ( $key in $subKeys ) {

    $adapterKeyPath = Join-Path -Path $keyPath -ChildPath $key
    $adapterReg = Get-Item $adapterKeyPath
    
    #Set location to HKLM: to make sure Get-ItemProperty cmdlet doesn't fail
    Set-Location HKLM:
    
    #We only want adapters that contain the word "Surface" anywhere in the description
    if ( $adapterReg.GetValue("DriverDesc") -like "*Surface Ethernet Adapter*" ) {
        
        $advancedProperties = $adapterReg.Property
        
        foreach ( $prop in $advancedProperties ) {
            $propValue = Get-ItemProperty -Path $adapterReg -Name $prop
            
            switch ($prop) {
                
                $PROP_WakeOnMagicPacket {
                    if($propValue.$prop -eq 1) {
                        $BOOL_WakeOnMagicPacket = $true
                    }
                }
                
                $PROP_EnergyEfficientEthernet {
                    if($propValue.$prop -eq 0) {
                        $BOOL_EnergyEfficientEthernet = $true
                    }
                }
                
                $PROP_SelectiveSuspend {
                    if($propValue.$prop -eq 0) {
                        $BOOL_SelectiveSuspend = $true
                    }
                }
                
                default {}
            }
        
        }
    
    }

}

if ( $BOOL_WakeOnMagicPacket -and $BOOL_EnergyEfficientEthernet -and $BOOL_SelectiveSuspend ) {
    return $true
}
else {
    return $false
}