### Setup for Win32ShutdownTracker Method of Win32_OperatingSystem WMI class
### https://msdn.microsoft.com/en-us/library/aa394057%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
$CONST_Comment = "This workstation must be restarted to finalize the Wake-On-Lan Settings that were recently applied."
$CONST_ReasonCode = 0
$CONST_Flags = 6                                   # 6 is the flag for "Forced Reboot" 

### Setup our reboot time
$today = Get-Date
$rebootTime = Get-Date -Hour 02 -Minute 00 -Second 00

### If $rebootTime has already passed for the day, we need to add a day to our $rebootTime variable
if ($today -gt $rebootTime) {
    $rebootTime = $rebootTime.AddDays(1)
}
[int]$secondsUntilReboot = ($rebootTime - $today).TotalSeconds

### Query all enabled "Ethernet" devices
$nics = Get-WmiObject Win32_NetworkAdapter -Filter "netenabled = 'true'" | Where-Object {$_.AdapterType -match "Ethernet"}

foreach ($dev in $nics) {

    ### We need the PNPDeviceID 
    $devID = $dev.PNPDeviceID
        
    $devWakeEnable = Get-WmiObject MSPower_DeviceWakeEnable -Namespace root\wmi |
        Where-Object { $_.InstanceName -match [regex]::Escape($devID)}

    ### devWakeEnable will be $null (i.e. empty) if the network adapter is not WOL compatible, so we need to test if it exists
    if ($devWakeEnable) {
            
        if($devWakeEnable.Enable -eq $false) {
            $devWakeEnable.Enable = $true
            $devWakeEnable.psbase.Put()
        }

    }
           
}

### We need to reboot the device in order for the settings to take effect 
$win32_os = Get-WmiObject Win32_OperatingSystem
$win32_os.psbase.Scope.Options.EnablePrivileges = $true
$win32_os.Win32ShutdownTracker($secondsUntilReboot, $CONST_Comment, $CONST_ReasonCode, $CONST_Flags)