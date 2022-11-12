
# Install PowerHTML on demand
If (-not (Get-Module -ErrorAction Ignore -ListAvailable PowerHTML)) {
    Write-Verbose "Installing PowerHTML module for the current user..."
    Install-Module PowerHTML -Scope CurrentUser -ErrorAction Stop
}
Import-Module PowerHTML -Scope Global -ErrorAction Stop

# Ensures that Invoke-WebRequest uses TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# common request headers
$global:headers = @{
  "Content-Type"="text/xml; charset=utf-8";
  "Accept-Encoding"="gzip" 
}

Function global:GetAgent{
  # Choose a random user-agent
  $agents = [Microsoft.PowerShell.Commands.PSUserAgent]
  $x=(Get-random -Minimum 1 -Maximum $agents.GetProperties().count)
  return $agents.GetProperties()[$x-1]
}

Function global:SetPageHeader {
  param (
    [string] $html
  )
  $htmlDom = ConvertFrom-Html([System.Web.HttpUtility]::HtmlDecode($page))
  $tab = $htmlDom.SelectSingleNode('//table')
  $tab.id = "news-table"
  $root = $htmlDom.SelectSingleNode('//head')
  $nodes = @('<link rel="shortcut icon" href="res/favicon.ico"/>'
             '<link rel="stylesheet" href="res/dark.css" media="(prefers-color-scheme: dark)" />'
             '<link rel="stylesheet" href="res/light.css" media="(prefers-color-scheme: light)" />'
             '<meta http-equiv="refresh" content="120"/>'
             '<meta charset="utf-8"/>')
  
  foreach($entry in $nodes){
    $node = [HtmlAgilityPack.HtmlNode]::CreateNode($entry)
    $root.childNodes.Add($node)
  }

  return $htmlDom.OuterHtml
}

Function global:WritePage {
  param (
    [string] $html,
    [string] $path
  )
  $html | Out-File -FilePath $path -Encoding utf8
  Write-Output $html 
}

  ## used for parallell processing with old powershell-versions
Function global:Worker($Script, $List, $params = $null, $maxTreads = 8){

  $sessionstate = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
  $UserFunctions = @( Get-ChildItem function:\)

  if($UserFunctions.count -gt 0) {
     foreach ($FunctionDef in $UserFunctions) {
        if($FunctionDef.Name -ne $MyInvocation.MyCommand){
          $sessionstate.Commands.Add((New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList $FunctionDef.Name, $FunctionDef.ScriptBlock))
        }
     }
  }

  $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $maxTreads, $sessionstate, $Host)
  $RunspacePool.Open()
  $Jobs = @()

  foreach($entry in $List) {
     $Job = [powershell]::Create().AddScript($Script).AddArgument($entry).AddArgument($params)
     $Job.RunspacePool = $RunspacePool
     $Jobs += New-Object PSObject -Property @{
        RunNum = $_
        Pipe = $Job
        Result = $Job.BeginInvoke()
     }
  }

  Do {
    Start-Sleep -Milliseconds 100
  } While ( $Jobs.Result.IsCompleted -contains $false)

  $Results = @()
  ForEach ($Job in $Jobs)
  {   #collect results here
      $pmg = $Job.Pipe.EndInvoke($Job.Result)
      $Results += $pmg
      $Job.Pipe.Dispose()
  }

  $RunspacePool.Close()
  $RunspacePool.Dispose()
  return $Results
}

$global:agent = global:GetAgent
