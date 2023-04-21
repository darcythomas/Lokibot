param (
  [Parameter(Mandatory)]
  [System.IO.FileInfo]$path
)


if ( -Not ($path | Test-Path) ) {
  Write-Host "File or folder does not exist"
}
else {
  Remove-Item $path -Recurse -Force
  Write-Host "Cleaned: " + $path

}

mkdir $path -Force

Write-Host "Created: " + $path
