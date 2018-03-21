$cmClientUserSettings = [WmiClass]"\\.\ROOT\ccm\ClientSDK:CCM_ClientUXSettings"
$autoInstallSetting = $cmClientUserSettings.GetAutoInstallRequiredSoftwaretoNonBusinessHours()
return $autoInstallSetting.AutomaticallyInstallSoftware