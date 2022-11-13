 
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
