### Information about the Win32_EncryptableVolume WMI class can be found here at:
###   https://msdn.microsoft.com/en-us/library/windows/desktop/aa376483(v=vs.85).aspx

$isCompliant = $true
$wmiBitlocker = Get-WmiObject -Class Win32_EncryptableVolume -Namespace root\CIMV2\Security\MicrosoftVolumeEncryption
$keyProtectors = $wmiBitlocker.GetKeyProtectors()

switch ($keyProtectors.VolumeKeyProtectorID.Count) 
{
    0 
        { $isCompliant = $false }
    
    1 
        {
      
            ### If the Key Protector Type is "Numerical Password" (i.e. Type=3), then there is no TPM protector
            if($wmiBitlocker.GetKeyProtectorType($keyProtectors.VolumeKeyProtectorID).KeyProtectorType -eq 3) {
                $isCompliant = $false
            }
      
        }

    default #If there are any other number of Key Protectors
        {

            foreach ($id in $keyProtectors.VolumeKeyProtectorID) {
                
                $type = $wmiBitlocker.GetKeyProtectorType($id)
                
                ### KeyProtectorType 4 is "TPM and PIN" 
                if ($type.KeyProtectorType -eq 4) {
                
                    $isCompliant = $false
                
                }
            
            }
        
        }

}


return $isCompliant