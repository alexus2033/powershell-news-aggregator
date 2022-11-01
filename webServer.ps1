# Install Polaris WebServer https://github.com/PowerShell/Polaris
If (-not (Get-Module -ErrorAction Ignore -ListAvailable Polaris)) {
  Write-Verbose "Installing Polaris module for the current user..."
  Install-Module Polaris -Scope CurrentUser -ErrorAction Stop
}
Import-Module Polaris -ErrorAction Stop

$global:httpRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $global:httpRoot
if($Env:DEBUG){
    Write-Host "http-root: $($global:httpRoot)"    
}

# Handle root-folder
New-PolarisRoute -Path /*.html -Method GET -ScriptPath .\cacheHandler.ps1

# Use static serving of a res-directory
New-PolarisStaticRoute -FolderPath ./res -RoutePath /res -EnableDirectoryBrowser $True

# Start the server
$app = Start-Polaris -Port 8800 -MinRunspaces 1 -MaxRunspaces 5 -Verbose # all params are optional

while($app.Listener.IsListening){
    Wait-Event callbackcomplete
}

# Stop the server
Stop-Polaris
