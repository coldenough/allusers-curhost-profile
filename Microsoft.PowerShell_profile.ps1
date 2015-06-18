<#
cd C:\Users\dkoldunov\Documents\GitHub\allusers-curhost-profile
$dest = Split-Path $PROFILE.AllUsersCurrentHost
cp .\Microsoft.PowerShell_profile.ps1 $dest
#>
cd 'c:/'

# Aliases
Set-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"

function getParam {Get-Parameter $Args[0] -ShowCommon}
Set-Alias gpm getParam

# Modules

if (Get-Module -ListAvailable -Name PsGet) {
  Write-Verbose 'PsGet already installed'
} else {
  Invoke-Expression (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
}

if (Get-Module PsReadLine) {
  Write-Verbose 'PsReadLine already installed'
} else {
  Install-Module PsReadLine
}

# Functions

function Get-Parameter ( $Cmdlet, [switch]$ShowCommon, [switch]$Full ) {

	$command = Get-Command $Cmdlet -ea silentlycontinue 

	# resolve aliases (an alias can point to another alias)
	while ($command.CommandType -eq "Alias") {
		$command = Get-Command ($command.definition)
	}
	if (-not $command) { return }

	foreach ($paramset in $command.ParameterSets){
		$Output = @()
		foreach ($param in $paramset.Parameters) {
			if ( ! $ShowCommon ) {
				if ($param.aliases -match "vb|db|ea|wa|ev|wv|ov|ob|wi|cf") { continue }
			}
			$process = "" | Select-Object Name, Type, ParameterSet, Aliases, Position, IsMandatory,
			Pipeline, PipelineByPropertyName
			$process.Name = $param.Name
			if ( $param.ParameterType.Name -eq "SwitchParameter" ) {
				$process.Type = "Boolean"
			}
			else {
				switch -regex ( $param.ParameterType ) {
					"Nullable``1\[(.+)\]" { $process.Type = $matches[1].Split('.')[-1] + " (nullable)" ; break }
					default { $process.Type = $param.ParameterType.Name }
				}
			}
			if ( $paramset.name -eq "__AllParameterSets" ) { $process.ParameterSet = "Default" }
			else { $process.ParameterSet = $paramset.Name }
			$process.Aliases = $param.aliases
			if ( $param.Position -lt 0 ) { $process.Position = $null }
			else { $process.Position = $param.Position }
			$process.IsMandatory = $param.IsMandatory
			$process.Pipeline = $param.ValueFromPipeline
			$process.PipelineByPropertyName = $param.ValueFromPipelineByPropertyName
			$output += $process
		}
		if ( ! $Full ) { 
			$Output | Select-Object Name, Type, ParameterSet, IsMandatory, Pipeline
		}
		else { Write-Output $Output }
	}
}

If ($host.Name -eq 'ConsoleHost') {
  import-module PSReadline
}

# Clear