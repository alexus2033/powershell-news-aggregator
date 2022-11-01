# Cache Handler for Polaris WebServer
# deliver html-pages and execute corresponding powershell (.ps1) files

$timeout = 15
$path = [Uri]$Request.Url
$file = $path.LocalPath.replace('/','')

if($Env:DEBUG){
    Write-Host "Request: $path"    
}

# look for connected network adapters
if($ENV:OS.StartsWith("Windows")){
    $online = $Null -ne (get-wmiobject win32_networkadapter -filter "netconnectionstatus = 2")
} else { # linux?
    $online = $True
}

$html = Join-Path $global:httpRoot $file
$script = (Split-Path $html -parent) + "\"
$script += [System.IO.Path]::GetFileNameWithoutExtension($html) + "Reader.ps1"

# html file found
if(Test-Path "$html"){
    $Response.ContentType = "text/html"
    $file = get-item $html
    # check, if timeout was reached
    $refresh = ($online -and ($file.lastWriteTime.addMinutes($timeout) -lt (Get-Date)))
    if($Request.Query['refresh']){
       # ignore timeout
       $refresh = ($Request.Query['refresh'] -eq "1")
    }
    if(($refresh -eq $True) -and (Test-Path "$script")){
        # execute script to generate new html
        $result = Invoke-Expression "$script"
        $Response.Send($result)
        return
    }
    # read html-file from cache
    $page = Get-Content "$html" -encoding UTF8
    $Response.Send($page)
    return
}

# no html found, but powershell is available
if(Test-Path "$script"){
    $Response.ContentType = "text/html"
    # execute script to generate new html  
    $result = Invoke-Expression "$script"
    $Response.Send($result)
    return
}

$Response.StatusCode=404
if($Env:DEBUG){
    $Response.Send("Debug: $html was not found.")    
} else {
    $Response.Send("Sorry, $file was not found.")
}