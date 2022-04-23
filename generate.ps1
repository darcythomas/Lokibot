$Path = "$PSScriptRoot\src\template\"


& "$PSScriptRoot\src\generateScripts\clean.ps1" -path "$Path"
& "$PSScriptRoot\src\generateScripts\create.ps1" -path "$Path"