Clear-Host

Search-ADAccount -LockedOut | Out-GridView -PassThru | Unlock-ADAccount
# |  Select-Object Name, SamAccountName, LastLogonDate, ObjectClass, LockedOut
