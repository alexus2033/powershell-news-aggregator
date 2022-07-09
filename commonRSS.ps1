Function global:ReadRSS([string[]] $feeds, $maxEntries = 1){

  # Ensures that Invoke-WebRequest uses TLS 1.2
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

  $ReportData = [System.Collections.ArrayList]@()

  foreach($rss in $feeds){
    $webResult = Invoke-RestMethod -Uri $rss -UserAgent $global:agent -Headers $global:headers
    if($webResult.count -eq 0) { break }

    if($webResult[0].title -is [array]){
       $title = $webResult[0].title[0]
    } elseif ($webResult[0].title.innertext) {
       $title = $webResult[0].title.innertext
    } else {
       $title = $webResult[0].title
    }
    
    $chanTitle = ($rss -split "^(?:https?:\/\/)?(?:[^@\/\n]+@)?(?:www\.)?([^:\/?\n]+)")[1]
    if($webResult[0].author.name -ne $null){
      $chanTitle = $webResult[0].author.name
    } elseif ($webResult[0].author -ne $null){
      $chanTitle = $webResult[0].author
    }

    if($webResult[0].published -ne $null){
        $blubb = [datetime]$webResult[0].published
    } elseif ($webResult[0].pubdate -ne $null) {
        $blubb = [datetime]$webResult[0].pubdate
    } else {
        $blubb = $webResult[0].date -replace "T"," "
        $blubb = [datetime]($blubb.substring(0,19))
    }

    if($webResult[0].link.href -ne $null){
      $link = $webResult[0].link.href
    } elseif($webResult[0].link.innertext -ne $null){ 
      $link = $webResult[0].link.innertext
    } else {
      $link = $webResult[0].link
    }

    $row = New-Object PSObject -Property @{
      Channel = $chanTitle
      Title = $title
      Link  = "<a href='$link' target='_blank'>$chanTitle</a>"
      Date  = $blubb.ToLocalTime()
    }
    $ReportData.Add($row) > $null;
  }
  return $ReportData
}
