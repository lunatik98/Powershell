### HEAD ###

Clear-Host

$UserCredential = Get-Credential

$Name = $args[0]
$Author = $args[1]
$Reviewer = $args[2]

#$Name = Read-Host "Name des öffentlichen Ordners"
#$Author = Read-Host "Soll ein Authorzugriff erstellt werden?"
#$Reviewer = Read-Host "Soll ein Prüferzugriff erstellt werden?"

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

# öffentlichen Ordner erstellen
New-PublicFolder -Name $Name | Out-Null
Write-Host "öffentlicher Ordner wurde erstellt"

# Mail für Ordner aktivieren
Enable-MailPublicFolder \$Name | Out-Null

# Standartberechtigungen entfernen
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
    Description        = "Benutzer dieser Gruppe haben Editorberechtigung auf den öffentlichen Ordner $Name"
}
New-ADGroup OL_"$Name"_Editor @ParamsEditor -PassThru | Out-Null
Write-Host "Sicherheitsgruppe "OL_"$Name"_Editor" wurde erstellt"

Start-Sleep -s 15

# Mail für die Sicherheitsgruppe aktivieren
Enable-DistributionGroup -Identity OL_"$Name"_Editor | Out-Null

# Sicherheitsgruppe im Addressbuch ausblenden
Get-DistributionGroup -RecipientTypeDetails MailUniversalSecurityGroup -Identity OL_"$Name"_Editor | Set-DistributionGroup -HiddenFromAddressListsEnabled:$true | Out-Null

# Sicherheitsgruppe Berechtigungen auf Ordner erteilen
Add-PublicFolderClientPermission -Identity "\$Name" -User OL_"$Name"_Editor -AccessRights Editor | Out-Null

# AUTHOR #

if ($Author -like "*ja*"){

    # Sicherheitsgruppe erstellen
    $ParamsAuthor =@{
        Path               = "OU=Öffentliche Ordner,OU=Berechtigungsgruppen,DC=bkh-lohr,DC=local"
        GroupCategory      = "Security"
        GroupScope         = "Universal"
        Description        = "Benutzer dieser Gruppe haben Autorberechtigung auf den öffentlichen Ordner $Name"
    }
    New-ADGroup OL_"$Name"_Autor @ParamsAuthor -PassThru | Out-Null
    Write-Host "Sicherheitsgruppe "OL_"$Name"_Autor" wurde erstellt"
    
    Start-Sleep -s 15

    # Mail für die Sicherheitsgruppe aktivieren
    Enable-DistributionGroup -Identity OL_"$Name"_Autor | Out-Null

    # Sicherheitsgruppe im Addressbuch ausblenden
    Get-DistributionGroup -RecipientTypeDetails MailUniversalSecurityGroup -Identity OL_"$Name"_Autor | Set-DistributionGroup -HiddenFromAddressListsEnabled:$true | Out-Null

    # Sicherheitsgruppe Berechtigungen auf Ordner erteilen
    Add-PublicFolderClientPermission -Identity "\$Name" -User OL_"$Name"_Autor -AccessRights Author | Out-Null
}

# REVIEWER #

if ($Reviewer -like "*ja*"){

    # Sicherheitsgruppe erstellen
    $ParamsReviewer =@{
        Path               = "OU=Öffentliche Ordner,OU=Berechtigungsgruppen,DC=bkh-lohr,DC=local"
        GroupCategory      = "Security"
        GroupScope         = "Universal"
        Description        = "Benutzer dieser Gruppe haben Leseberechtigung auf den öffentlichen Ordner $Name"
    }
    New-ADGroup OL_"$Name"_Prüfer @ParamsReviewer -PassThru | Out-Null
    Write-Host "Sicherheitsgruppe "OL_"$Name"_Prüfer" wurde erstellt"
    
    Start-Sleep -s 15
    
    # Mail für die Sicherheitsgruppe aktivieren
    Enable-DistributionGroup -Identity OL_"$Name"_Prüfer | Out-Null
    
    # Sicherheitsgruppe im Addressbuch ausblenden
    Get-DistributionGroup -RecipientTypeDetails MailUniversalSecurityGroup -Identity OL_"$Name"_Prüfer | Set-DistributionGroup -HiddenFromAddressListsEnabled:$true | Out-Null
    
    # Sicherheitsgruppe Berechtigungen auf Ordner erteilen
    Add-PublicFolderClientPermission -Identity "\$Name" -User OL_"$Name"_Prüfer -AccessRights Reviewer | Out-Null
    }

### END ###

Get-PublicFolderClientPermission -Identity "\$Name" | Format-Table -Autosize

Remove-PSSession $Session

