[CmdletBinding()]
Param(
    [string] $String = "Ala ma kota",
    [switch] $Decrypt
)

function Encrypt() {
    Param(
    [Parameter(Mandatory=$true, Position=0)]
        $String
    )
     
    $password = Read-Host -AsSecureString -Prompt "Input Encryption Key"

    # Ideal solution would be to pass -SecureKey, but couldn't make it work yet
    $key = (New-Object pscredential('u',$password)).GetNetworkCredential().Password
    $key = ([byte[]] $key.ToCharArray())

    if(($key.Count % 8) -ne 0) { "Key lenght must be multiplication of 8" }

    $String = $String | ConvertTo-SecureString -AsPlainText -Force
    $encrypted = $String | ConvertFrom-SecureString -Key $key

    $encrypted
 }

 function Decrypt() {
    Param(
    [Parameter(Mandatory=$true, Position=0)]
        $encString
    )

    $password = Read-Host -AsSecureString -Prompt "Input Encryption Key"
    $key = (New-Object pscredential('u',$password)).GetNetworkCredential().Password
    $key = ([byte[]] $key.ToCharArray())

    if(($key.Count % 8) -ne 0) { "Key lenght not valid" }

    $decrypted = $encString | ConvertTo-SecureString -Key $key 
    $decrypted = (New-Object pscredential('u',$decrypted)).GetNetworkCredential().Password

    $decrypted
 }

 if($Decrypt.IsPresent) { Decrypt $String }
 else { Encrypt $String }

