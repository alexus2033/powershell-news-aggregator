
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
  $charSet = [HtmlAgilityPack.HtmlNode]::CreateNode('<meta charset="utf-8"/>')
  $test.childNodes.Add($favIcon)
  $test.childNodes.Add($charSet)
  return $htmlDom.OuterHtml
  }

  function global:WritePage {
    param (
      [string] $html,
      [string] $path
    )
    $html | Out-File -FilePath $path -Encoding utf8
    Write-Output $html 
  }
  
  $global:agent = global:GetAgent