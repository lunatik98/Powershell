Clear-Host

Search-ADAccount -LockedOut | Out-GridView -PassThru | Unlock-ADAccount
