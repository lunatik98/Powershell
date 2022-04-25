### HEAD ###

# Name des öffentlichen Kalenders
$Name = $args[0]

# Soll ein Authorzugriff erstellt werden?
$Author = $args[1]

# Soll ein Prüferzugriff erstellt werden?
$Reviewer = $args[2]

# Login
$Path = "\\bkh-lohr.local\dfs\abteilung$\EDV\Soft_Hardware\_Skripts\EasyJob\scripts\Import\Passwort_Serveradmin.txt"
$Username = "admmarius"
$Password =  Get-Content $Path | ConvertTo-SecureString -AsPlainText -Force
$UserCredential = New-Object System.Management.Automation.PsCredential $Username, $Password

# Verbindung zu Exchange
$ParamsConnection = @{
    ConfigurationName   = "Microsoft.Exchange"
    ConnectionUri       = "http://exchange2019/PowerShell/"
    Authentication      = "Kerberos"
    Credential          = $UserCredential
}
$Session = New-PSSession @ParamsConnection  
Import-PSSession $Session -DisableNameChecking -AllowClobber | Out-Null

### MAIN ###

# öffentlicher Kalender muss in Outlook als Serveradmin erstellt werden

# Mail für Kalender aktivieren
Enable-MailPublicFolder \$Name | Out-Null

# Standartberechtigungen entfernen
Remove-PublicFolderClientPermission -Identity "\$Name" -User $UserCredential.UserName -Confirm:$false | Out-Null
Remove-PublicFolderClientPermission -Identity "\$Name" -User Standard -Confirm:$false | Out-Null
Remove-PublicFolderClientPermission -Identity "\$Name" -User Anonym -Confirm:$false | Out-Null
Add-PublicFolderClientPermission -Identity "\$Name" -User Standard -AccessRights CreateItems | Out-Null
Add-PublicFolderClientPermission -Identity "\$Name" -User Anonym -AccessRights CreateItems | Out-Null

# EDITOR #

# Sicherheitsgruppe erstellen
$ParamsEditor =@{
    Path               = "OU=Öffentliche Ordner,OU=Berechtigungsgruppen,DC=bkh-lohr,DC=local"
    GroupCategory      = "Security"
    GroupScope         = "Universal"
    Description        = "Benutzer dieser Gruppe haben Editorberechtigung auf den öffentlichen Kalender $Name"
}
New-ADGroup OL_"$Name"_Editor @ParamsEditor -PassThru | Out-Null
Write-Host "Sicherheitsgruppe "OL_"$Name"_Editor" wurde erstellt"

Start-Sleep -s 15

# Mail für die Sicherheitsgruppe aktivieren
Enable-DistributionGroup -Identity OL_"$Name"_Editor | Out-Null

# Sicherheitsgruppe im Addressbuch ausblenden
Get-DistributionGroup -RecipientTypeDetails MailUniversalSecurityGroup -Identity OL_"$Name"_Editor | Set-DistributionGroup -HiddenFromAddressListsEnabled:$true | Out-Null

# Sicherheitsgruppe Berechtigungen auf Kalender erteilen
Add-PublicFolderClientPermission -Identity "\$Name" -User OL_"$Name"_Editor -AccessRights Editor | Out-Null

# AUTHOR #

if ($Author -like "*ja*"){

    # Sicherheitsgruppe erstellen
    $ParamsAuthor =@{
        Path               = "OU=Öffentliche Ordner,OU=Berechtigungsgruppen,DC=bkh-lohr,DC=local"
        GroupCategory      = "Security"
        GroupScope         = "Universal"
        Description        = "Benutzer dieser Gruppe haben Autorberechtigung auf den öffentlichen Kalender $Name"
    }
    New-ADGroup OL_"$Name"_Autor @ParamsAuthor -PassThru | Out-Null
    Write-Host "Sicherheitsgruppe "OL_"$Name"_Autor" wurde erstellt"
    
    Start-Sleep -s 15

    # Mail für die Sicherheitsgruppe aktivieren
    Enable-DistributionGroup -Identity OL_"$Name"_Autor | Out-Null

    # Sicherheitsgruppe im Addressbuch ausblenden
    Get-DistributionGroup -RecipientTypeDetails MailUniversalSecurityGroup -Identity OL_"$Name"_Autor | Set-DistributionGroup -HiddenFromAddressListsEnabled:$true | Out-Null

    # Sicherheitsgruppe Berechtigungen auf Kalender erteilen
    Add-PublicFolderClientPermission -Identity "\$Name" -User OL_"$Name"_Autor -AccessRights Author | Out-Null
}

# REVIEWER #

if ($Reviewer -like "*ja*"){

    # Sicherheitsgruppe erstellen
    $ParamsReviewer =@{
        Path               = "OU=Öffentliche Ordner,OU=Berechtigungsgruppen,DC=bkh-lohr,DC=local"
        GroupCategory      = "Security"
        GroupScope         = "Universal"
        Description        = "Benutzer dieser Gruppe haben Leseberechtigung auf den öffentlichen Kalender $Name"
    }
    New-ADGroup OL_"$Name"_Prüfer @ParamsReviewer -PassThru | Out-Null
    Write-Host "Sicherheitsgruppe "OL_"$Name"_Prüfer" wurde erstellt"
    
    Start-Sleep -s 15
    
    # Mail für die Sicherheitsgruppe aktivieren
    Enable-DistributionGroup -Identity OL_"$Name"_Prüfer | Out-Null
    
    # Sicherheitsgruppe im Addressbuch ausblenden
    Get-DistributionGroup -RecipientTypeDetails MailUniversalSecurityGroup -Identity OL_"$Name"_Prüfer | Set-DistributionGroup -HiddenFromAddressListsEnabled:$true | Out-Null
    
    # Sicherheitsgruppe Berechtigungen auf Kalender erteilen
    Add-PublicFolderClientPermission -Identity "\$Name" -User OL_"$Name"_Prüfer -AccessRights Reviewer | Out-Null
    }

### END ###

Get-PublicFolderClientPermission -Identity "\$Name" | Format-Table -Autosize
Remove-PSSession $Session
