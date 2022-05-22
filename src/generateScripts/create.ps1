

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



function Create-Tests {

    $folder =  "tests";
    dotnet new xunit -o "$path$folder\unit" --name "$name.UnitTests"
    dotnet new xunit -o "$path$folder\intergration" --name "$name.IntergrationTests"
    dotnet new console -o "$path$folder\performance" --name "$name.PerformanceTests"

    Push-Location
    Set-Location "$path$folder\performance"
    
    dotnet add package  BenchmarkDotNet 

$basicBenchMarkCode = @"
 
using System.Security.Cryptography;
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Running;


var summary = BenchmarkRunner.Run(typeof(Program).Assembly);

public class Md5VsSha256
    {
        private const int N = 10000;
        private readonly byte[] data;

        private readonly SHA256 sha256 = SHA256.Create();
        private readonly MD5 md5 = MD5.Create();

        public Md5VsSha256()
        {
            data = new byte[N];
            new Random(42).NextBytes(data);
        }

        [Benchmark]
        public byte[] Sha256() => sha256.ComputeHash(data);

        [Benchmark]
        public byte[] Md5() => md5.ComputeHash(data);
    }
"@


$basicBenchMarkCode | Out-File "Program.cs"


dotnet add reference "$path\services\$name.Services.csproj"

    Pop-Location

}

function Create-ServiceProject {

    $folder =  "services";
    dotnet new classlib -o "$path\$folder" --name "$name.Services"

}
function Create-DataAccessProjects {

    $folder =  "dataAccess";
    dotnet new classlib -o "$path\$folder\sql" --name "$name.DataAccess.SQL"
    dotnet new classlib -o "$path\$folder\blob" --name "$name.DataAccess.Blob"


    Set-Location "$path\$folder"

    Push-Location
    Set-Location "sql"
    
    dotnet add reference "$path\services\$name.Services.csproj"
    

    Pop-Location
    
    Push-Location
    Set-Location "blob"
    
    dotnet add reference "$path\services\$name.Services.csproj"

    Pop-Location
    
    
    Pop-Location

}

function Create-FrontendProjects {

    $folder =  "frontend";
    dotnet new razorclasslib -o "$path$folder\api" --name "$name.frontend.api"
    dotnet new razorclasslib -o "$path$folder\presentation" --name "$name.frontend.presentation"
}


function Create-RootApp {

    $folder =  "app";

    Push-Location
    dotnet new razor -o "$path\$folder" --name "$name.App"

    Set-Location "$path\$folder"

dotnet add reference "$path\services\$name.Services.csproj"

dotnet add reference ($path + "dataAccess\sql\$name.DataAccess.SQL.csproj")

dotnet add reference ($path + "dataAccess\blob\$name.DataAccess.Blob.csproj")

dotnet add reference ($path + "frontend\api\$name.frontend.api.csproj")

dotnet add reference ($path + "frontend\presentation\$name.frontend.presentation.csproj")



dotnet add package Swashbuckle.AspNetCore


((Get-Content -path "$path$folder\Program.cs" -Raw) -replace 'builder.Services.AddRazorPages','cofffffeeeeee') | Write-Host


(Get-Content -path "$path$folder\Program.cs" -Raw) -replace 'builder.Services.AddRazorPages','builder.Services.AddRazorPages;' | Out-File  "$path$folder\Program.cs"


Pop-Location
}
    

Push-Location 
Set-Location $path


Setup-Template
Create-ServiceProject
Create-DataAccessProjects
Create-RootApp
Create-Tests



Pop-Location


