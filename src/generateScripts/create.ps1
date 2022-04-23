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

dotnet new razor
$templateJson = @"
{
    "`$schema": "http://json.schemastore.org/template",
    "author": "Me",
    "classifications": [ "Common", "Code" ],
    "identity": "ExampleTemplate.StringExtensions",
    "name": "Example templates: string extensions",
    "shortName": "stringext",
    "tags": {
      "language": "C#",
      "type": "item"
    }
}
"@


$templateFolder =  ".template.config";
mkdir $templateFolder
$templateJson | Out-File "$path\$templateFolder\template.json"



mkdir 'services'
mkdir 'dataAccess'
mkdir 'tests'
mkdir 'frontend'

Pop-Location
#dotnet --help