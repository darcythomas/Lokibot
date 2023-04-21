

param (

  [Parameter(Mandatory)]
  [ValidateScript({
      if ( -Not ($_ | Test-Path) ) {
        throw "File or folder does not exist"
      }
      return $true
    })]
  [System.IO.FileInfo]
  $path,

  [Parameter(Mandatory)]
  [ValidateScript({
      if ( [string]::IsNullOrEmpty( $_ ) ) {
        throw "Name is blank"
      }
      return $true
    })]
  [System.String]
  $name
)

    

$projects = @()



function Create-Tests {

  $folder = "tests";
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

  $folder = "services";
  dotnet new classlib -o "$path\$folder" --name "$name.Services"
  
  $projects += "$path\services\$name.Services.csproj"

}
function Create-DataAccessProjects {

  $folder = "dataAccess";

  dotnet new classlib -o "$path\$folder\sql" --name "$name.DataAccess.SQL"
  $projects += ($path + "dataAccess\sql\$name.DataAccess.SQL.csproj")

  dotnet new classlib -o "$path\$folder\blob" --name "$name.DataAccess.Blob"
  $projects += ($path + "dataAccess\blob\$name.DataAccess.Blob.csproj")


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

  $folder = "frontend";

  dotnet new razorclasslib -o "$path$folder\api" --name "$name.frontend.api"
  $projects += ($path + "frontend\api\$name.frontend.api.csproj")

  dotnet new razorclasslib -o "$path$folder\presentation" --name "$name.frontend.presentation"    
  $projects += ($path + "frontend\presentation\$name.frontend.presentation.csproj")
}


function Create-RootApp {

  $folder = "EntryPoint";

  Push-Location
  dotnet new razor -o "$path\$folder" --name "$name.App"

  Set-Location "$path\$folder"


  $projects | % {
    dotnet add reference $_
  }






  dotnet add package Swashbuckle.AspNetCore


  $token = 'builder.Services.AddRazorPages();'
  $toAdd = '//hi'


(Get-Content -path "Program.cs" -Raw).Replace( $token , $token + "`n" +  $toAdd) | Out-File  "Program.cs"


  Pop-Location
}
    

Push-Location 
Set-Location $path



#Create-ServiceProject
#Create-DataAccessProjects
Create-RootApp
#Create-Tests



Pop-Location

