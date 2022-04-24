

param (

    [Parameter(Mandatory)]
    [ValidateScript({
        if( -Not ($_ | Test-Path) ){
            throw "File or folder does not exist"
        }
        return $true
    })]
    [System.IO.FileInfo]
    $path
    )

    
$name = "Coffee"
$author = "Darcy"

function Setup-Template {
   
$templateJson = @"
    {
        "`$schema": "http://json.schemastore.org/template",
        "author": "$author",
        "classifications": [ "Common", "Code" ],
        "identity": "ExampleTemplate.StringExtensions",
        "name": "Example templates: string extensions",
        "shortName": "$name",
        "tags": {
          "language": "C#",
          "type": "item"
        }
    }
"@
    
    $folder =  ".template.config";
    mkdir $folder
    $templateJson | Out-File "$path\$folder\template.json"
       
}



function Create-RootApp {

    $folder =  "app";
    dotnet new razor -o "$path\$folder" --name $name

}
function Create-Tests {

    $folder =  "tests";
    dotnet new xunit -o "$path$folder\unit" --name $name
    dotnet new xunit -o "$path$folder\intergration" --name $name
    dotnet new console -o "$path$folder\performance" --name $name

    Push-Location
    Set-Location "$path$folder\performance"
    
    dotnet add package  BenchmarkDotNet 
    Pop-Location

}

function Create-ServiceProject {

    $folder =  "services";
    dotnet new classlib -o "$path\$folder" --name "$name.Services"

}


    

Push-Location 
Set-Location $path


Setup-Template
Create-RootApp
Create-Tests
Create-ServiceProject


mkdir 'dataAccess'

mkdir 'frontend'

Pop-Location


