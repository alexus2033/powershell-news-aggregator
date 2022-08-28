Function global:readRSS([string[]] $rssList, $maxFeedItems = 1){

  $readRSS={
    param( [String]$rssFeed,
           $maxFeedItems = 1 )
 
    # Ensures that Invoke-WebRequest uses TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $newsList = [System.Collections.ArrayList]@()

    $webResult = Invoke-RestMethod -Uri $rssFeed -UserAgent GetAgent #-Headers $global:headers
    if($webResult.count -eq 0) { break }

    for($x=0;$x -le $maxFeedItems-1;$x++)
    {
        if($webResult[$x].title -is [array]){
            $title = $webResult[$x].title[0]
        } elseif ($webResult[$x].title.innertext) {
            $title = $webResult[$x].title.innertext
        } else {
            $title = $webResult[$x].title
        }
    
        $chanTitle = ($rssFeed -split "^(?:https?:\/\/)?(?:[^@\/\n]+@)?(?:www\.)?([^:\/?\n]+)")[1]
        if($webResult[$x].author.'#cdata-section'){
          $chanTitle =$webResult[$x].author.'#cdata-section'
        } elseif($webResult[$x].author.name){
          $chanTitle = $webResult[$x].author.name
        } elseif ($webResult[$x].author){
          $chanTitle = $webResult[$x].author
        }

        if($webResult[$x].published){
          $pubDate = [datetime]$webResult[$x].published
        } elseif ($webResult[$x].date) {
          $pubDate = $webResult[$x].date -replace "T"," "
          $pubDate = [datetime]($blubb.substring(0,19))
        } else {
          $pubDate = $webResult[$x].pubdate
        }

        if($webResult[$x].link.href){
          $link = $webResult[$x].link.href
        } elseif($webResult[$X].link.innertext){ 
          $link = $webResult[$X].link.innertext
        } else {
          $link = $webResult[$x].link
        }

        $row = New-Object PSObject -Property @{
          Channel = $chanTitle
          Title = $title
          Link  = "<a href='$link' target='_blank'>$chanTitle</a>"
          Date  = $pubDate
        }
        $newsList.Add($row) > $null;
    }
    return $newsList
  }

  $resultList = global:Worker $readRSS $rssList 1
  return $resultList

}
