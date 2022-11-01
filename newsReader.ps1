
$channels = @(
    'UCipwt-3-cptv9K6uhfZ61GA' #aeronews
    'UCu7_D0o48KbfhpEohoP7YSQ' #andreas spiess
    'UCp_5PO66faM4dBFbFFBdPSQ' #bitluni
    'UC6mIxFTvXkWQVEHPsEdflzQ' #great scott
    'UC2DjFE7Xf11URZqWBigcVOQ' #EEV Blog
    'UC1t9VFj-O6YUDPQxaVg-NkQ' #c't 3003
    'UCafxR2HWJRmMfSdyZXvZMTw' #look,mum no computers
    'UC8Ob-HnnmhlgSv5Vs_i32TQ' #Ralph S Bacon
    'UCzml9bXoEM0itbcE96CB03w' #DroneBot Workshop
    'UCS_4e-9t5uzJaRyE6YKZ6rQ' #Geek Week
    'UCsnGwSIHyoYN0kiINAGUKxg' #Wolfgang
    #'UCES01Gvu_3JkQE6ZU44na6A' #Futorial
)

$feeds = @(
    'https://www.spiegel.de/netzwelt/index.rss' #spiegel netzwelt
    'https://feeds.metaebene.me/lnp/m4a'   #logbuch netzpolitik
    'https://www.heise.de/rss/heise.rdf'   #heise news
    'https://die-hupe.podigee.io/feed/mp3' #die Hupe
     #'https://feeds.br.de/umbruch-der-tech-podcast-von-br24/feed.xml'
    'https://feeds.br.de/das-computermagazin/feed.xml'
    'https://www.deutschlandfunk.de/computer-und-kommunikation-102.xml'
    'https://rss.golem.de/rss.php?feed=RSS2.0'
    'https://www.gsmarena.com/rss-news-reviews.php3'
    'https://t3n.de/tag/podcast/rss.xml'
    'https://digitec.podigee.io/feed/mp3' #faz digitec
    'https://www.derstandard.at/rss/web' #der standard (web)
    'https://podcast.hr.de/freiheit-deluxe/podcast.xml'
    'https://lanz-precht.podigee.io/feed/mp3'
    'https://www.pschatzmann.ch/home/feed/'
    #'https://www.volksfreund.de/region/trier-trierer-land/feed.rss'
)

.\common.ps1
.\commonRSS.ps1
.\commonVideo.ps1

$pageTitle="Tech-News"
$Report = [System.Collections.ArrayList]@()
$entries = global:ReadVideoList $channels
$Report.AddRange($entries)
$entries = global:ReadRSSList $feeds
$Report.AddRange($entries)

# prepare html-table
$timestamp = Get-Date -Format "HH:mm"
$ReportHeader ="<div class='header'><h1>$pageTitle</h1><div class='timestamp'>$timestamp</div></div>"
$ReportFooter = @("<br><a href='?refresh=1'>update</a><script src=res/moment.js></script>
        <script src=res/table.js></script>")

# switch to script-folder
Push-Location $PSScriptRoot

# Create an HTML table and write it to "news.html"
$page = ($Report |  Sort-Object {$_.Date -as [DateTime]} -Descending | Select-Object Date, Title ,@{N='Channel';E={$_.Link}} | ConvertTo-Html -title $pageTitle -PreContent "$($ReportHeader)" -PostContent "$($ReportFooter)")

$html = SetPageHeader $page 
writePage $html "news.html"
