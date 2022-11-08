# powershell-news-aggregator
local Webserver for your favorite RSS-Feeds and Youtube-Channels

## Dependencies
- [Polaris](https://powershell.github.io/Polaris/) tiny server framework
- [Power HTML](https://github.com/JustinGrote/PowerHTML) for parsing and manipulating HTML

## Quick Setup (local)
1. [Download Repo](https://github.com/alexus2033/powershell-news-aggregator/archive/refs/heads/main.zip) and unzip content on your local disc
2. Edit feeds in [demoReader.ps1](/demoReader.ps1)
3. Run powershell *webServer.ps1* to start the service
4. Open http://localhost:8800/demo.html in your Web-Browser

## Docker Setup
- docker build -t newsserver .
- docker run -d -p 8800:8800 newsserver
