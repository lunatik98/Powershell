# Benutzername
$User = $args[0]

# Login
$Path = "\\bkh-lohr.local\dfs\abteilung$\EDV\Soft_Hardware\_Skripts\EasyJob\scripts\Import\Passwort_Serveradmin.txt"
$Username = "admmarius"
$Password =  Get-Content $Path | ConvertTo-SecureString -AsPlainText -Force
$UserCredential = New-Object System.Management.Automation.PsCredential $Username, $Password

$ParamsConnection = @{
    ConfigurationName   = "Microsoft.Exchange"
    ConnectionUri       = "http://exchange2019/PowerShell/"
    Authentication      = "Kerberos"
    Credential          = $UserCredential
}
$Session = New-PSSession @ParamsConnection    
Import-PSSession $Session -CommandName Enable-Mailbox -AllowClobber | Out-Null

Enable-Mailbox -Identity $User@bkh-lohr.local

Remove-PSSession $Session