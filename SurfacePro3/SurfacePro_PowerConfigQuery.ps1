### Return variable for SCCM Baseline
$isCompliant = $true

### A hash table of power settings that need to be monitored
$desiredSettings = @{
    "USB 3 Link Power Mangement"=0;   ### Yes, "Mangement" is how the setting is spelled in the registry, this is NOT a typo
    "USB selective suspend setting"=0;
    "Console lock display off timeout"=900;
}

###  Query for the active power plan
$powerPlan = Get-WmiObject -Namespace "root\cimv2\power" -Class Win32_PowerPlan | Where-Object {$_.IsActive}

###  We need to get the data index values for the active power plan
$powerPlanIndex = $powerPlan.GetRelated("Win32_PowerSettingDataIndex")

###  Loop through the index values and look for any USB power setting entries
foreach ($index in $powerPlanIndex) {

    ### Look at the actual power setting that this index value references
    $setting = $index.GetRelated("Win32_PowerSetting")
        
    ### We need to parse the InstanceIDs to find the settings for the AC Power Type
    ### The index Instance ID takes the format of "Microsoft:PowerSettingDataIndex\{PowerPlan GUID}\{Power Type}\{PowerSetting GUID}
    $indexInstanceID = $index.InstanceID.Split("\")
    $ACorDC = $indexInstanceID[2]
    
    ### If the ElementName field contains the string "USB" AND the PowerSetting is for AC (Plugged in)
    if ( ($setting.ElementName -in $desiredSettings.Keys) -and ($ACorDC -eq "AC") ) {
        
        ### Query the value of the current setting
        $value = $index.GetPropertyValue("SettingIndexValue")

        if ( $value -ne $desiredSettings[$setting.ElementName] ) {
            $isCompliant = $false
            return $isCompliant
        }
    }
}
return $isCompliant