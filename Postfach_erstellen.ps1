# Get-Mailbox Fehler verbergen
$ErrorActionPreference =  "SilentlyContinue"

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
Import-PSSession $Session -CommandName Enable-Mailbox,Get-Mailbox -AllowClobber | Out-Null

if (Get-Mailbox -Identity $User@bkh-lohr.local)
{
    Write-Host "Postfach existiert bereits"
}

else 
{
    Enable-Mailbox -Identity $User@bkh-lohr.local -Database "MDB19-200MB" | Out-Null

    if (Get-Mailbox -Identity $User@bkh-lohr.local)
    {
        Write-Host "Postfach wurde erstellt"
    }

    else
    {
        Write-Host "Postfach konnte nicht erstellt werden"
    }
}

Remove-PSSession $Session