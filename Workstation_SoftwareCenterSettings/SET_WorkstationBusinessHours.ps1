$startTime = 5
$endTime = 20
$workingDays = 127
$cmClientUserSettings = [WmiClass]"\\.\ROOT\ccm\ClientSDK:CCM_ClientUXSettings"
$businessHours = $cmClientUserSettings.PSBase.GetMethodParameters("SetBusinessHours")
$businessHours.StartTime = $StartTime
$businessHours.EndTime = $EndTime
$businessHours.WorkingDays = $WorkingDays
 
Try {
 $result = $cmClientUserSettings.PSBase.InvokeMethod("SetBusinessHours", $businessHours, $Null)
 If ($result.ReturnValue -eq 0 ) {
 "Success."
 }
 Else {
 "Failed to set SCCM client business hours."
 }
}
Catch {
 "Failed to set SCCM client business hours."
}