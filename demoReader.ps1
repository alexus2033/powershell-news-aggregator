﻿# Powershell-Script to generate "http://localhost:8800/demo.html"
# Use this example to create your personal news-portal

$pageTitle = "Tech-News Demo"

# list of RSS-Feeds
$feeds = @(
    'https://www.techrepublic.com/rssfeeds/articles/'     #Tech-Republic
    'https://www.computerweekly.com/rss/IT-security.xml'  #add your favorites here!
)
$maxFeedItems = 3

# list of YouTube-Channels,
# add only the last part of url: https://www.youtube.com/channel/UCAuUUnT6oDeKwE6v1NGQxug
$channels = @(
    'UCAuUUnT6oDeKwE6v1NGQxug' #TED video channel
    'UCAY_M9HyJb8oMKPV1utQQyA' #TechRadar
    'UC6mIxFTvXkWQVEHPsEdflzQ' #great scott
    'UC2DjFE7Xf11URZqWBigcVOQ' #EEV Blog
    'UCafxR2HWJRmMfSdyZXvZMTw' #look,mum no computers
)
$maxChanItems = 3

# switch to script-folder
Push-Location $PSScriptRoot
.\common.ps1

$ReportData = [System.Collections.ArrayList]@()

.\commonRSS.ps1
$newsFeeds = ReadRSSList $feeds $maxFeedItems
$ReportData.Addrange($newsFeeds)

.\commonVideo.ps1
$videos = ReadVideoList $channels $maxChanItems
$ReportData.Addrange($videos)

# prepare html-table
$timestamp = Get-Date -Format "HH:mm"
$ReportHeader ="<div class='header'><h1>$pageTitle</h1><div class='timestamp'>$timestamp</div></div>
<div class='row'><div class='column'>"
$ReportFooter = @("</div>
    <div class='infocolumn'><h2>Details...</h2>
    </div></div><br><a href='?refresh=1'>update</a><script src=res/moment.min.js></script>
    <script src=res/table.js></script>")

# Create an HTML table
$page = ($ReportData |  Sort-Object {$_.Date -as [DateTime]} -Descending | Select-Object Date, Title ,@{N='Channel';E={$_.Link}}, Description | 
                        ConvertTo-Html -title $pageTitle -PreContent "$($ReportHeader)" -PostContent "$($ReportFooter)")
                    
# Set html-headers and save it to "demo.html"
$html = SetPageHeader $page 
WritePage $html "demo.html"