<#
File location:
cp ./Profile.ps1 C:\Users\dkoldunov\Documents\WindowsPowerShell
#>

# PSDrives
New-PSDrive -Name Git -PSProvider FileSystem `
    -Root 'C:\Users\dkoldunov\Documents\GitHub\' `
    -Description 'dkoldunov@ drive'

# Aliases
$nppAliasPath = "C:\Program Files (x86)\Notepad++\notepad++.exe"
if (Test-Path $nppAliasPath) {
  Set-Alias -Name npp -Value $nppAliasPath -Description 'dkoldunov@ aliases' `
      -Option ReadOnly
} #end of if

#Modules
Import-Module PSReadLine

# Posh Git
# Load posh-git example profile
. (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
. (Resolve-Path "$env:github_posh_git\profile.example.ps1")