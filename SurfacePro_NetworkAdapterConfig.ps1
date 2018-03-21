#Property names for the registry keys we want to change
$PROP_WakeOnMagicPacket = "*WakeOnMagicPacket"
$PROP_EnergyEfficientEthernet = "EEE"
$PROP_SelectiveSuspend = "*SelectiveSuspend"

#This is the location in HKEY_LOCAL_MACHINE that stores the information about Network adapters
$keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"
$networkRegKey = Get-Item $keyPath

#We only want the subkeys that are #### (i.e. 0001, 0002, etc...) as they correspond to the actual network adapters
$subKeys = $networkRegKey.GetSubKeyNames() | Where-Object {$_ -match "\d\d\d\d"}

#Iterate through each network adapter subkey
foreach ( $key in $subKeys ) {

    $adapterKeyPath = Join-Path -Path $keyPath -ChildPath $key
    $adapterReg = Get-Item $adapterKeyPath
    
    #We only want adapters that contain the word "Surface" anywhere in the description
    if ( $adapterReg.GetValue("DriverDesc") -like "*Surface*" ) {
    
        $advancedProperties = $adapterReg.Property
        
        foreach ( $prop in $advancedProperties ) {
            
            switch ($prop) {
                #Enable Wake on Magic Packet
                $PROP_WakeOnMagicPacket {Set-ItemProperty -Path $adapterReg -Name $prop -Value 1}
                #Disable Energy Efficient Ethernet
                $PROP_EnergyEfficientEthernet {Set-ItemProperty -Path $adapterReg -Name $prop -Value 0}
                #Disable Selective Suspend
                $PROP_SelectiveSuspend {Set-ItemProperty -Path $adapterReg -Name $prop -Value 0}
                #Default does nothing (i.e. ignore any other property)
                default {}
            }
        
        }
    
    }

}