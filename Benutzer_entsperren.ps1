# Login
$TXT = "\\bkh-lohr.local\dfs\abteilung$\EDV\Soft_Hardware\_Skripts\EasyJob\scripts\Import\Passwort_Serveradmin.txt"
$Username = "admmarius"
$Password =  Get-Content $TXT | ConvertTo-SecureString -AsPlainText -Force
$UserCredential = New-Object System.Management.Automation.PsCredential $Username, $Password

# Remotepowershell verbinden
$Session = New-PSSession -ComputerName "DC02" -Credential $UserCredential

Invoke-Command -Session $Session -ScriptBlock{    
    
    if (Search-ADAccount -UsersOnly -LockedOut) {
        Search-ADAccount -UsersOnly -LockedOut | Select-Object Name, SamAccountName, LastLogonDate | Format-Table
        Search-ADAccount -UsersOnly -Lockedout | Unlock-AdAccount
        Write-Host " "
        Write-Host "Alle gesperrten Benutzer wurden entsperrt"
    }
    else {
        Write-Host "Keine gesperrten Benutzer vorhanden"
    }      
}
Remove-PSSession $Session