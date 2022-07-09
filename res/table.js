window.onload = () => {

    // Find the table
    const dataTable = document.querySelector('table')

    // Give it an ID so it's easier to work with for CSS or subsequent JS
    dataTable.id = 'news-table'

    // Move the first row into a THEAD element that PowerShell doesn't add but is necessary for sorting
    const headerRow = dataTable.querySelector('tr:nth-child(1)')
    const thead = document.createElement('thead')
    thead.appendChild(headerRow)

    dataTable.prepend(thead)
    myTimer()
    // Update Times every 50 Secs
    setInterval(myTimer, 50000);

    function myTimer() {
        const col1=Array.from(document.querySelectorAll('#news-table tr td:nth-child(1)'));
        col1.forEach(function(item){
            if(item.hasAttribute("Timestamp")){
                var ts=item.getAttribute("Timestamp")
            } else {
                console.info(item.nodeValue);
                var ts=item.innerHTML;
                item.setAttribute("Timestamp",ts)
            }
            var newText=moment(ts,'DD-MMM-YYYY HH:mm a').fromNow()
            item.innerHTML=newText;
        })
    }
}
