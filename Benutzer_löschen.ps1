### HEAD ###

$Users = Get-Content "\\bkh-lohr.local\dfs\abteilung$\EDV\Soft_Hardware\_Skripts\EasyJob\scripts\Import\Benutzer_löschen.txt"

### MAIN ###

foreach ($User in $Users)
{
    $Folder1 = "\\bkh-lohr.local\dfs\Ordnerumleitung$\Folder\$User"
    $Folder2 = "\\bkh-lohr.local\dfs\Ordnerumleitung$\Desktop\$User"
    $Folder3 = "\\bkh-lohr.local\dfs\user$\$User"
    $Folder4 = "\\bkh-lohr.local\dfs\Profile$\$User.V6"

    if (Get-ADUser -Filter {SamAccountName -eq $User})
        {
        Remove-ADUser -Identity $User -Confirm:$false
        Write-Host "Benutzer $User wurde gelöscht"

        if (Test-Path -Path $Folder1) 
        {Remove-Item -LiteralPath $Folder1 -Force -Recurse}

        if (Test-Path -Path $Folder2) 
        {Remove-Item -LiteralPath $Folder2 -Force -Recurse}

        if (Test-Path -Path $Folder3) 
        {Remove-Item -LiteralPath $Folder3 -Force -Recurse}

        if (Test-Path -Path $Folder4) 
        {Remove-Item -LiteralPath $Folder4 -Force -Recurse}
        
        Write-Host "Ordner von $User wurden gelöscht"
        }
    
    else 
        {
        Write-Host "\c04EJBenutzer $User wurde nicht gefunden/c04EJ"
        }
}


