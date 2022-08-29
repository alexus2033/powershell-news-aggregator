# Powershell-Script to generate "http://localhost:8800/ebay.html"

# List your product-keywords here:
$searchList = @(
  'Denon+DBT'
  'Denon+DN'
  'Denon+DN-M2300r'
  'DEQ2496'
)

$pageTitle = "Ebay-Watch"
$Ebay = "https://www.ebay.de"

.\common.ps1

$ReportData = [System.Collections.ArrayList]@()

foreach($product in $searchList) {
    $searchLink="$Ebay/dsc/i.html?_ipg=200&_nkw=$product&_rss=1&rt=nc"
    $webResult = Invoke-RestMethod -Uri $searchLink -UserAgent $agent -Headers $global:headers -ErrorAction Stop
    if($webResult.count -eq 0) { break }

    foreach($item in $webResult)
    {
      if($item.title -is [array]){
          $title = $item.title[0]
      } elseif ($item.title.innertext) {
          $title = $item.title.innertext
      } else {
          $title = $item.title
      }
    
      if($item.published -ne $null){
        $pubDate = Get-Date $item.published
      } elseif ($item.date -ne $null) {
        $pubDate = $item.date -replace "T"," "
        $pubDate = Get-Date ($pubDate.substring(0,19))
      } else {
        $pubDate = $item.pubdate -replace " MST"
        $pubDate = Get-Date $pubDate
      }

      $Description = $item.description."#cdata-section"
      $ENDDATE_REGEX = [regex] ".*(End Date: <span>+)(?'EndDate'[^<]+).*"
      if($description -match $ENDDATE_REGEX) {
        $EndDate = $Matches.EndDate
        $d = $EndDate -split ' '
        $realDate = "{0}{1}{2} {3}" -f $d[0],$d[1],(Get-Date).Year,$d[2]
        $CloseDate = Get-Date $realDate -Format("dd.MMM.yyyy HH:mm")
        $CloseDate = [datetime]$CloseDate
        if((Get-Date).Month -gt $CloseDate.Month){
          $CloseDate.AddYears(1)
        }
      }

      $IMAGE_REGEX = [regex] ".*(src=`"+)(?'ImageSrc'[^`"]+).*"
			if($description -match $IMAGE_REGEX) {
				$imgLink = $Matches.ImageSrc
			}

      $cat = $item.Category.'#cdata-section'
      $BidCount = $item.BidCount."#text"
        
      $cp = $item.CurrentPrice."#text"
      if ($cp) {
        $CurrentPrice = [int]$cp/100
      } else {
        $CurrentPrice = "?"
      }

      $bn = $item.BuyItNowPrice."#text"
      if($bn -gt 0){
        $BuyItNowPrice = [int]$bn/100
      } else {
        $BuyItNowPrice = ""
      }

      if($item.link.href){
        $link = $item.link.href
      } elseif($item.link.innertext){ 
        $link = $item.link.innertext
      } else {
        $link = $item.link
      }

      #$bytes = [System.Text.Encoding]::Unicode.GetBytes($link)
      #$jsLink =[Convert]::ToBase64String($bytes)
      $moob="<a data=""$link"" href='javascript:markDBEntry(""$link"",""$title"",""$cat"");'>Marker</a>"

      $row = New-Object PSObject -Property @{
        Channel = $chanTitle
        Title = "<a href='$link' onpointerenter=""showImage('$imgLink')"" onpointerleave=""hideImage()"" target='_blank'>$title</a>"
        Category  = $cat
        Published  = $pubDate
        EndDate = $CloseDate
        Bids = $BidCount
        Price = $CurrentPrice
        FixPrice = $BuyItNowPrice
        Action = $moob
      }
      $ReportData.Add($row) > $null;
    }
}

# prepare html-table
$timestamp = Get-Date -Format "HH:mm"
$ReportHeader ="<div class='header'><h1>$pageTitle</h1><div class='timestamp'>$timestamp</div></div>"
$ReportFooter = @("<br><a href='?refresh=1'>update</a><img id='floatingimg' onerror=""javascript: alert('failure')""></img>
        <script src=res/tsorter.min.js></script>
        <script src=res/moment.js></script>
        <script src=res/dexie.min.js></script>
        <script src=res/ebayTable.js></script>")

# switch to script-folder
Push-Location $PSScriptRoot

# Create a sorted HTML table
$page = ($ReportData |  Sort-Object {$_.EndDate -as [DateTime]} | Select-Object Published, EndDate, Title, FixPrice, Price, Bids, Category | ConvertTo-Html -CSSUri res/dark.css -title $pageTitle -PreContent "$ReportHeader" -PostContent "$ReportFooter")

$html = global:SetPageHeader $page 
global:writePage $html "ebay.html"
