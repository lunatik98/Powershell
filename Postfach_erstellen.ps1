$UserCredential = Get-Credential

$Username = $args[0]

#$Username = Read-Host "Benutzername"

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