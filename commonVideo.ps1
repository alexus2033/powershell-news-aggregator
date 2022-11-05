﻿
function FormatMore([int]$count, $name){
  if($count -eq 1){ return "{0} {1} ago" -f $count,$name }
  return "{0} {1}s ago" -f $count,$name
}

# Display time ago
function FormatTime($timestamp){
  $start = [datetime]$timestamp
  #$start = $start.ToLocalTime()
  $ts = New-TimeSpan -Start $start -End (GET-DATE)
  $weeks = [Math]::Truncate($ts.Days/5)
  if($weeks -gt 0){
     return FormatMore $weeks "week"
  }
  if($ts.Days -gt 0){
     return FormatMore $ts.Days "day"
  }
  if($ts.Hours -gt 0){
     return FormatMore $ts.Hours "hour"
  }
  return FormatMore $ts.Minutes "minute"
}

function global:CalcTime([string]$info){
    $part = $info -split '\s+'
    if($part[1] -match '^[0-9]+$'){
        $number = [int]$part[1]
        if($part[2].StartsWith("minute")){
            return (get-date).AddMinutes($number*-1)
        }
        if($part[2].StartsWith("hour")){
            return (get-date).AddHours($number*-1)
        }
        if($part[2].StartsWith("day")){
            return (get-date).AddDays($number*-1)
        }
        if($part[2].StartsWith("week")){
            return (get-date).AddDays($number*-7)
        }
        if($part[2].StartsWith("month")){
        return (get-date).AddDays($number*-30)
        }
    }
    if($part[2] -match '^[0-9]+$'){
        $number = [int]$part[2]
        if($part[3].StartsWith("minuto")){
            return (get-date).AddMinutes($number*-1)
        }
        if($part[3].StartsWith("horas")){
            return (get-date).AddHours($number*-1)
        }
        if($part[3].StartsWith("semana")){
            return (get-date).AddDays($number*-7)
        }
        if($part[3].StartsWith("d")){  #compartido hace 2 días
            return (get-date).AddDays($number*-1)
        }
        if($part[3].StartsWith("mes")){
            return (get-date).AddDays($number*-30)
        }
    }
    return $info
}
 
function global:ReadVideoUrl($index = 1){
   # Ensures that Invoke-WebRequest uses TLS Versions
   [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12, tls11, tls"
   $videoSearch = "https://api.invidious.io/instances.json?pretty=1&sort_by=type,health"

   $videoPages = Invoke-WebRequest $videoSearch -UserAgent $global:agent -ErrorAction Stop | ConvertFrom-Json
   return $videoPages[$index].uri
}

Function global:readVideoList {
  
    param([string[]] $channels,
          [int] $maxChanItems = 1 )
  
    $readRSSFunction = (Get-ChildItem function:\readRSS).ScriptBlock
    
    $videoURL = global:ReadVideoUrl
    for ($x = 0; $x -lt $channels.Count; $x++) {
      $channels[$x]="$videoURL/feed/channel/$($channels[$x])"
    }
    $resultList = global:Worker $readRSSFunction $channels $maxChanItems
    
    return $resultList
  }

function global:ReadInvidious{
   
    param( [String]$chan,
            [string]$videoSearch,
            [int]$maxChanItems = 1 )
    
    # Ensures that Invoke-WebRequest uses TLS Versions
    [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12, tls11, tls"
    $newsList = [System.Collections.ArrayList]@()

    $webResult = Invoke-WebRequest "$videoSearch/channel/$chan" -UserAgent GetAgent #-Headers global:headers
    $htmldom = ConvertFrom-Html $webResult
  
    $chanTitle = $htmldom.SelectNodes("//div/div[@class='channel-profile']/span")
  
    for($x=1;$x -le $maxChanItems;$x++)
    {
        $title = $htmldom.SelectNodes("//div[@class='pure-g']/div[$x]/div[@class='h-box']/a/p")
  
        $link =  $htmldom.SelectNodes("//div[@class='pure-g']/div[$x]/div/a")
        $link = $videoSearch + $link.getattributevalue("href","")
  
        $timestamp = $htmldom.SelectNodes("//div[1]/div/div[@class='video-card-row flexible']/div[@class='flex-left']/p[@class='video-data']")
        $timeText = [System.Web.HttpUtility]::HtmlDecode($timestamp.innerText)
  
        $row = New-Object PSObject -Property @{
        Channel = $chanTitle.innerhtml
        Title = "<a href='$link' target='_blank'>$($
        title.innerhtml)</a>"
        Link  = "<a href='$videoSearch/channel/$chan' target='_blank'>$($chanTitle.innerhtml)</a>"
        Date = (CalcTime $timeText)
        }
        # put one row together...                                  
        $newsList.Add($row) > $null;
    }
    return $newsList  
}
