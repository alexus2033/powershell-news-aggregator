## Get entries of different ATOM/RSS-Feeds
Function global:readRSSList {
  
  param([string[]] $rssList,
        [int] $maxFeedItems = 1 )

  $readRSSFunction = (Get-ChildItem function:\readRSS).ScriptBlock

  $resultList = global:Worker $readRSSFunction $rssList $maxFeedItems

  return $resultList
}

## Get entries of one ATOM/RSS-Feed
Function global:readRSS{
    
    param([String]$rssFeed,
          [int] $maxFeedItems = 1 )
 
    # Ensures that Invoke-WebRequest uses TLS Versions
    [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12, tls11, tls"
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
          $pubDate = [datetime]($pubDate.substring(0,19))
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

        $tags = @('Description','Summary','Content')
        foreach($tag in $tags){
          if($webResult[$x].$tag){
            $desc = global:getHtmlContent $webResult[$x].$tag $tag
            break
          }
        }
  
        $row = New-Object PSObject -Property @{
          Channel = $chanTitle
          Title = "<a href='$link' target='_blank'>$title</a>"
          Link  = "<a href='$link' target='_blank'>$chanTitle</a>"
          Description = $desc
          Date  = $pubDate
        }
        $newsList.Add($row) > $null;
    }
  return $newsList
}

## try to get HTML-Tags, remove Javascript
Function global:getHtmlContent{
    
  param([Object]$something,
        [string]$tagName)
  
  if($something.'#cdata-section'){
     $something = $something.'#cdata-section'
  }
  if($something.'#text'){
     $something = $something.'#text'
  }
  if($something -is [Xml.XmlElement]){
      $something = $something.outerXML
  }

  $doc = New-Object HtmlAgilityPack.HtmlDocument
  $doc.LoadHtml($something);
  if($doc.SelectNodes("//script").Count -gt 0){
      Write-Host "Removing JavaScript..." 
      $doc.SelectNodes("//script").RemoveAll()
  }
  if($doc.SelectSingleNode("//$tagName")){
    return $doc.SelectSingleNode("//$tagName").InnerHtml
  }
  return $doc.DocumentNode.InnerHtml

}