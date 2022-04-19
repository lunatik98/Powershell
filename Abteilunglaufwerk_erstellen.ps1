### HEAD ###

Clear-Host

$Name = $args[0]
$Read = $args[1]

#$Name = Read-Host "Name des Abteilungslaufwerks"
#$Read = Read-Host "Soll ein Lesezugriff erstellt werden?"

$NameWrite = $Name
$NameWrite += "_schreiben"
$NameRead = $Name
$NameRead += "_lesen"

### MAIN ###

# Ordner erstellen
New-Item -Path M:\$Name -ItemType Directory | Out-Null
Write-Host "Ordner $Name wurde erstellt"

# LESEN #

if ($Read -like "*ja*"){
    # Sicherheitsgruppe erstellen
    $Params =@{
        Path               = "OU=Abteilungslaufwerke,OU=Berechtigungsgruppen,DC=bkh-lohr,DC=local"
        GroupCategory      = "Security"
        GroupScope         = "Global"
        Description        = "Benutzer dieser Gruppe haben Leseberechtigung auf den Ordner $Name"
    }
    New-ADGroup $NameRead @Params -PassThru | Out-Null
    Write-Host "Sicherheitsgruppe $NameRead wurde erstellt"

    Start-Sleep -s 15

    #Berechtigungen setzen
    $Permissions = Get-ACL -Path M:\$Name
    $PermissionsNew = New-Object System.Security.AccessControl.FileSystemAccessRule(“bkh-lohr\$NameRead”,”ReadAndExecute“,"ContainerInherit,ObjectInherit","None",”Allow”)
    $Permissions.AddAccessRule($PermissionsNew)
    $Permissions | Set-Acl -Path M:\$Name 
}

# SCHREIBEN #

#Sicherheitsgruppe erstellen
$Params =@{
    Path               = "OU=Abteilungslaufwerke,OU=Berechtigungsgruppen,DC=bkh-lohr,DC=local"
    GroupCategory      = "Security"
    GroupScope         = "Global"
    Description        = "Benutzer dieser Gruppe haben Schreibberechtigung auf den Ordner $Name"
}
New-ADGroup $NameWrite @Params -PassThru | Out-Null
Write-Host "Sicherheitsgruppe $NameWrite wurde erstellt"

Start-Sleep -s 15

#Berechtigungen setzen
$Permissions = Get-ACL -Path M:\$Name
$PermissionsNew = New-Object System.Security.AccessControl.FileSystemAccessRule(“bkh-lohr\$NameWrite”,”Modify“,"ContainerInherit,ObjectInherit","InheritOnly",”Allow”)
$Permissions.AddAccessRule($PermissionsNew)
$Permissions | Set-Acl -Path M:\$Name 

$Permissions = Get-ACL -Path M:\$Name
$PermissionsNew = New-Object System.Security.AccessControl.FileSystemAccessRule(“bkh-lohr\$NameWrite”,”Write, ReadAndExecute“,”Allow”)
$Permissions.AddAccessRule($PermissionsNew)
$Permissions | Set-Acl -Path M:\$Name 

### END ###

Get-Acl M:\$Name | Select-Object -ExpandProperty Access | Format-Table -Autosize