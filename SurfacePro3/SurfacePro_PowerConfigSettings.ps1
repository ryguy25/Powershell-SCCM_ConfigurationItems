### These are our desired power settings and their respective values
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
        
    ### We need to parse the InstanceIDs to find the scheme GUID, subgroup GUID, setting GUID, and power type (AC or DC)
    ### The index Instance ID takes the format of "Microsoft:PowerSettingDataIndex\{PowerPlan GUID}\{AC or DC}\{PowerSetting GUID} 
    $indexInstanceID = $index.InstanceID.Split("\")
    $ACorDC = $indexInstanceID[2]    
    
    ### If the ElementName field contains the string "USB" AND the PowerSetting is for AC (Plugged in)
    if ( ($setting.ElementName -in $desiredSettings.Keys) -and ($ACorDC -eq "AC") ) {
        
        ### Change the setting value to 0 which is either "Off" or "Disabled"
        $index.SetPropertyValue( "SettingIndexValue", $desiredSettings[$setting.ElementName] )
        ### Save the value
        $index.Put() | Out-Null
    }
}

### You have to activate the powerplan for the changes to take affect
$powerPlan.Activate() | Out-Null
