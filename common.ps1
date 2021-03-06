
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
  $test = $htmlDom.SelectSingleNode('//head') 
  $favIcon = [HtmlAgilityPack.HtmlNode]::CreateNode('<link rel="shortcut icon" href="res/favicon.ico"/>')
  $refresh = [HtmlAgilityPack.HtmlNode]::CreateNode('<meta http-equiv="refresh" content="60"/>')
  $charSet = [HtmlAgilityPack.HtmlNode]::CreateNode('<meta charset="utf-8"/>')
  $test.childNodes.Add($favIcon)
  $test.childNodes.Add($refresh)
  $test.childNodes.Add($charSet)
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

  $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $maxTreads)
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
