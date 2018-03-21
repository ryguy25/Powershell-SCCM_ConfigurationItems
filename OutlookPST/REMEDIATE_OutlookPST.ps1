### Setup Event Log Source
if ([System.Diagnostics.EventLog]::SourceExists("SCCM DCM Script") -eq $false) {
    New-EventLog -LogName Application -Source "SCCM DCM Script"
}

#Check to see if Outlook is running before we create the ComObject
$isOutlookRunning = Get-Process -Name OUTLOOK -ErrorAction SilentlyContinue

$Outlook = New-Object -ComObject Outlook.Application
$Namespace = $Outlook.getNamespace("MAPI")
$Stores = $Namespace.Stores

$pstFiles = New-Object System.Collections.ArrayList

foreach ( $store in $Stores ) {

    $storeType = $store.ExchangeStoreType

    if ($storeType -eq 3) {

        #Pipe to Out-Null to suppress console output from the .Add() method
        $pstFiles.Add( $store.GetRootFolder() ) | Out-Null

    }
    
}

foreach ( $pst in $pstFiles ) {

    Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Information -EventId 0 `
            -Message "Attempting to remove PST: $($pst.Name)"

    Try {

        #$Outlook.Session.RemoveStore($pst)
        $folder = $Namespace.Folders.Item($pst.Name)
        $Namespace.GetType().InvokeMember('RemoveStore',[System.Reflection.BindingFlags]::InvokeMethod,$null,$Namespace,($folder))

    }

    Catch {

        Write-EventLog -LogName Application -Source "SCCM DCM Script" -EntryType Error -EventId 0 `
            -Message "Error trying to remove PST: $($pst.Name).  PowerShell threw the following error:  $($_.Exception.Message)"

    }

}

#region CLEANUP

if ( $isOutlookRunning ) {

    Write-EventLog -LogName "Application" -Source "SCCM DCM Script" -EntryType Information -EventId 0 `
        -Message "User has an active Outlook session, continue to let the program run."        

}

else {

    $Outlook.Quit()
    Write-EventLog -LogName "Application" -Source "SCCM DCM Script" -EntryType Information -EventId 0 `
        -Message "Called Quit() method to close the background application."

}

### Release the COM Object and associated memory
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($Outlook) | Out-Null
Remove-Variable -Name Outlook

#endregion CLEANUP