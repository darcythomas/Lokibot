param (

    [Parameter(Mandatory)]
    [ValidateScript({
        if( -Not ($_ | Test-Path) ){
            throw "File or folder does not exist"
        }
        return $true
    })]
    [System.IO.FileInfo]$path
    )


    Push-Location 
Set-Location $path
write-host "Starting $path"
dotnet new console
ls

Pop-Location
#dotnet --help