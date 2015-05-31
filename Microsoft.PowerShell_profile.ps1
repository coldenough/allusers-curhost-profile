cd 'c:/'

# Aliases
Set-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"

# Post Git
# Load posh-git example profile
# . (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
# . (Resolve-Path "$env:github_posh_git\profile.example.ps1")

#cd ~/Documents/GitHub


###############

$AvailableModuleCsv = "$env:Temp/AvailableModule.csv"
New-Item -ItemType file -Path $AvailableModuleCsv -Force | Out-Null

Get-Module -ListAvailable | Select-Object Name | Export-Csv -Path $AvailableModuleCsv -NoTypeInformation
$AvailableModuleList = ( Get-Content $AvailableModuleCsv ) | Select-Object -Skip 1
$AvailableModuleList

if ( Select-String -Path $AvailableModuleCsv -Pattern PsGet ){
  Write-Host
  Write-Verbose 'PsGet already installed'
  Write-Host
} else {
  Invoke-Expression (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
}


if ( Select-String -Path $AvailableModuleCsv -Pattern PsReadLine ){
  Write-Host
  Write-Verbose 'PsReadLine already installed'
  Write-Host
} else {
  Install-Module PsReadLine
}

######################

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
			$Output | Select-Object Name, Type, ParameterSet, IsMandatory, Pipeline | ft -AutoSize
		}
		else { Write-Output $Output }
	}
}

If($host.Name -eq 'ConsoleHost') {
  import-module PSReadline
}

Clear