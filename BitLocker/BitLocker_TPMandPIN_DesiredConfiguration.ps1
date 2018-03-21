$isProtectedWithTPM = $false
$wmiBitlocker = Get-WmiObject -Class Win32_EncryptableVolume -Namespace root\CIMV2\Security\MicrosoftVolumeEncryption
$keyProtectors = $wmiBitlocker.GetKeyProtectors()

foreach ($id in $keyProtectors.VolumeKeyProtectorID) {
    $type = $wmiBitlocker.GetKeyProtectorType($id)
    
    ### If "TPM" protector already exists we don't want to add another key protector.
    if ($type.KeyProtectorType -eq 1) {
        $isProtectedWithTPM = $true
    }

    ### If "TPM And PIN" protector exists, delete it.
    if ($type.KeyProtectorType -eq 4) {
        $wmiBitlocker.DeleteKeyProtector($id)
    }
}


### If a "TPM" protector doesn't exist, create one.
if ($isProtectedWithTPM -eq $false) {
    $result = $wmiBitlocker.ProtectKeyWithTPM()
    if($result.ReturnValue -ne 0) {
        $hexValue = [Convert]::ToString($result.ReturnValue, 16)
        Write-EventLog -LogName System -Source "TPM" -EntryType Error -EventId 1001 -Message "ProtectKeyWithTPM Method returned the following error $($hexValue).  See https://msdn.microsoft.com/en-us/library/windows/desktop/dd542648(v=vs.85).aspx for Error Codes."
    }
}