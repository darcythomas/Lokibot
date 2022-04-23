param (

    [Parameter(Mandatory)]
    # [ValidateScript({
    #     if( -Not ($_ | Test-Path) ){
    #         throw "File or folder does not exist"
    #     }
    #     return $true
    # })]
    [System.IO.FileInfo]$path
    )


 
Remove-Item $path -Recurse

mkdir $path