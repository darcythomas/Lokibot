$name = "Coffee"
$Path = "$PSScriptRoot\src\template\$name"


& "$PSScriptRoot\src\generateScripts\clean.ps1" -path "$Path"
& "$PSScriptRoot\src\generateScripts\create.ps1" -path "$Path" -name $name
