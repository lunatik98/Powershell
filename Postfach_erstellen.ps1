# Benutzername
$Username = $args[0]

# Login
$Username = "admmarius"
$Password = Get-Content "\\bkh-lohr.local\dfs\abteilung$\EDV\Soft_Hardware\_Skripts\EasyJob\scripts\Import\Passwort_Serveradmin.txt" | ConvertTo-SecureString
$UserCredential = New-Object System.Management.Automation.PsCredential($Username, $Password)

$ParamsConnection = @{
    ConfigurationName   = "Microsoft.Exchange"
    ConnectionUri       = "http://exchange2019/PowerShell/"
    Authentication      = "Kerberos"
    Credential          = $UserCredential
}
$Session = New-PSSession @ParamsConnection    
Import-PSSession $Session -CommandName Enable-Mailbox -AllowClobber | Out-Null

Enable-Mailbox -Identity $Username@bkh-lohr.local

Remove-PSSession $Session