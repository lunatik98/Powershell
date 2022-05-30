# Login
$Path = "\\bkh-lohr.local\dfs\abteilung$\EDV\Soft_Hardware\_Skripts\EasyJob\scripts\Import\Passwort_Serveradmin.txt"
$Username = "admmarius"
$Password =  Get-Content $Path | ConvertTo-SecureString -AsPlainText -Force
$UserCredential = New-Object System.Management.Automation.PsCredential $Username, $Password

# Remotepowershell verbinden
$Session = New-PSSession -ComputerName "DC02" -Credential $UserCredential

Invoke-Command -Session $Session -ScriptBlock{ 

    $UserCredential = $Using:UserCredential

    $ParamsConnection = @{
        ConfigurationName   = "Microsoft.Exchange"
        ConnectionUri       = "http://exchange2019/PowerShell/"
        Authentication      = "Kerberos"
        Credential          = $UserCredential
    }
    $Session2 = New-PSSession @ParamsConnection    
    Import-PSSession -CommandName Enable-Mailbox $Session2 -AllowClobber | Out-Null

    $CSV = "\\bkh-lohr.local\dfs\abteilung$\EDV\Soft_Hardware\_Skripts\EasyJob\scripts\Import\Benutzer.csv"

    # CSV importieren
    $ADUsers = Import-csv $CSV -Delimiter ";" -Encoding UTF8
    
    foreach ($User in $ADUsers)
    {	
        $Firstname 	    = $User.vorname
        $Lastname 	    = $User.nachname
        $Username 	    = $User.benutzername
        $Office         = $User.buero
        $Phone          = $User.rufnummer
        $State          = $User.bundesland
        $JobTitle       = $User.position
        $Department     = $User.abteilung
        $Description    = $User.beschreibung
        $OU             = $User.ou
        $Gender         = $User.geschlecht
        $Groups         = $User.gruppen

            # Überprüfen ob Benutzer existiert
        if (Get-ADUser -Filter {SamAccountName -eq $Username})
            {
            Write-Warning "Ein Benutzer mit dem Benutername $Username existiert bereits"
            }
        else
            {    
            # Passwort generieren
            function Get-RandomCharacters($length, $characters) 
            {
                $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
                $private:ofs=""
                return [String]$characters[$random]
            }
            $Password  = Get-RandomCharacters -length 1 -characters "BCDFGHJKLMNPRSTVWXZ"
            $Password += Get-RandomCharacters -length 1 -characters "aeiou"
            $Password += Get-RandomCharacters -length 1 -characters "bcdfghjklmnprstvxz"
            $Password += Get-RandomCharacters -length 1 -characters "aeiou"
            $Password += Get-RandomCharacters -length 1 -characters "bcdfghjklmnprstvxz"
            $Password += Get-RandomCharacters -length 1 -characters "aeiou"
            $Password += Get-RandomCharacters -length 1 -characters "bcdfghjklmnprstvxz"
            $Password += Get-RandomCharacters -length 1 -characters "aeiou"
            $Password += Get-RandomCharacters -length 1 -characters "#$%!+="
            $Password += Get-RandomCharacters -length 1 -characters '1234567890'

            # Benutzer erstellen
            New-ADUser `
                -Enabled $True `
                -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True `
                -Surname $Lastname `
                -GivenName $Firstname `
                -Name "$Firstname $Lastname" `
                -DisplayName "$Firstname $Lastname" `
                -SamAccountName $Username `
                -UserPrincipalName "$Username@bkh-lohr.local" `
                -Office $Office `
                -OfficePhone $Phone `
                -State $State `
                -Title $Jobtitle `
                -Department $Department `
                -Description $Description `
                -Path $OU `
                -OtherAttributes @{extensionAttribute1 = $Gender} `

                Write-Host "Benutzer $Username wurde angelegt mit Passwort: $Password"

            Start-Sleep -s 10

            # Postfach erstellen
            Enable-Mailbox -Identity $Username@bkh-lohr.local -Database "MDB19-200MB" | Out-Null
            Write-Host "Postfach für $Username wurde erstellt"

            # Benutzer zu Gruppen hinzufügen
            if ($Groups -ne "")
            {
                $Groups.Split(",") | ForEach-Object {
                Add-ADGroupMember -Identity $_ -Members $Username
                Write-Host "Benutzer $Username zu Gruppe $_ hinzugefügt" 
                }
            }

        }
    }
}
Remove-PSSession $Session


