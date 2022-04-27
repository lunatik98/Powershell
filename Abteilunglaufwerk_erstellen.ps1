### HEAD ###

# Name des Abteilungslaufwerks
$Name = $args[0]

# Soll ein Lesezugriff erstellt werden?
$Read = $args[1]

# Login
$TXT = "\\bkh-lohr.local\dfs\abteilung$\EDV\Soft_Hardware\_Skripts\EasyJob\scripts\Import\Passwort_Serveradmin.txt"
$Username = "admmarius"
$Password =  Get-Content $TXT | ConvertTo-SecureString -AsPlainText -Force
$UserCredential = New-Object System.Management.Automation.PsCredential $Username, $Password

# Remotepowershell verbinden
$Session = New-PSSession -ComputerName "DC02" -Credential $UserCredential

Invoke-Command -Session $Session -ScriptBlock{ 
    
    $Name = $Using:Name
    $Read = $Using:Read
    $NameWrite = $Name
    $NameWrite += "_schreiben"
    $NameRead = $Name
    $NameRead += "_lesen"
    $FolderPath = "\\bkh-lohr.local\dfs\abteilung$\$Name"

    ### MAIN ###

    # Ordner erstellen
    New-Item -Path $FolderPath -ItemType Directory | Out-Null
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
        $Permissions = Get-ACL -Path $FolderPath
        $PermissionsNew = New-Object System.Security.AccessControl.FileSystemAccessRule(“bkh-lohr\$NameRead”,”ReadAndExecute“,"ContainerInherit,ObjectInherit","None",”Allow”)
        $Permissions.AddAccessRule($PermissionsNew)
        $Permissions | Set-Acl -Path $FolderPath 
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
    $Permissions = Get-ACL -Path $FolderPath
    $PermissionsNew = New-Object System.Security.AccessControl.FileSystemAccessRule(“bkh-lohr\$NameWrite”,”Modify“,"ContainerInherit,ObjectInherit","InheritOnly",”Allow”)
    $Permissions.AddAccessRule($PermissionsNew)
    $Permissions | Set-Acl -Path $FolderPath 

    $Permissions = Get-ACL -Path $FolderPath
    $PermissionsNew = New-Object System.Security.AccessControl.FileSystemAccessRule(“bkh-lohr\$NameWrite”,”Write, ReadAndExecute“,”Allow”)
    $Permissions.AddAccessRule($PermissionsNew)
    $Permissions | Set-Acl -Path $FolderPath

    ### END ###

    Get-Acl $FolderPath | Select-Object -ExpandProperty Access | Format-Table -Autosize
}
Exit-PSSession 