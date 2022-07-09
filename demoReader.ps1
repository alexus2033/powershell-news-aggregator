$pageTitle = "Tech-News Demo"

$channels = @(
    'UCAuUUnT6oDeKwE6v1NGQxug' #TED video channel
)
$maxChanItems = 2

$feeds = @(
    'https://www.techrepublic.com/rssfeeds/articles/'
    'https://www.techradar.com/rss'
)
$maxFeedItems = 10

.\common.ps1

$ReportData = [System.Collections.ArrayList]@()

.\commonRSS.ps1
$newsFeeds = global:ReadRSS $feeds $maxFeedItems
$ReportData.Addrange($newsFeeds)

.\commonVideo.ps1
$videos = global:ReadInvidious $channels $maxChanItems
$ReportData.Addrange($videos)

# prepare html-table
$timestamp = Get-Date -Format "HH:mm"
$ReportHeader ="<div class='header'><h1>$pageTitle</h1><div class='timestamp'>$timestamp</div></div>"
$ReportFooter = @("<br><a href='?refresh=1'>update</a><script src=res/moment.js></script>
        <script src=res/table.js></script>")

# switch to script-folder
Push-Location $PSScriptRoot

# Create an HTML table
$page = ($ReportData |  Sort-Object {$_.Date -as [DateTime]} -Descending | Select-Object Date, Title ,@{N='Channel';E={$_.Link}} | ConvertTo-Html -CSSUri res/dark.css -title $pageTitle -PreContent "$($ReportHeader)" -PostContent "$($ReportFooter)")

# Set html-headers and save it to "demo.html"
$html = global:SetPageHeader $page 
global:writePage $html "demo.html"
