$cmClientUserSettings = [WmiClass]"\\.\ROOT\ccm\ClientSDK:CCM_ClientUXSettings"
$businessHours = $cmClientUserSettings.GetBusinessHours()
$businessHoursCI = "$([string]$businessHours.StartTime),$([string]$businessHours.EndTime),$([string]$businessHours.WorkingDays)"
Return $businessHoursCI