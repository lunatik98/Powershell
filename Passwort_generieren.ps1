Clear-Host

function Get-RandomCharacters($length, $characters) {
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
 
Write-Host $Password