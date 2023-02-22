window.onload = () => {

    const info = document.querySelector('div.infocolumn');

    // Find the table
    const dataTable = document.getElementById('news-table');

    // Move the first row into a THEAD element that PowerShell doesn't add but is necessary for sorting
    const headerRow = dataTable.querySelector('tr:nth-child(1)')
    const thead = document.createElement('thead')
    thead.appendChild(headerRow)

    dataTable.prepend(thead);
    myTimer();
    display_details();
    // Update Times every 50 Secs
    setInterval(myTimer, 50000);

    function display_details() {
        var table = document.getElementById('news-table');
        var cells = Array.from(document.querySelectorAll('#news-table tr td'));
        cells.forEach(function(item){
            item.onmouseover= function () {
                // Get the row id where the cell exists
                var rowId = this.parentNode.rowIndex;
                var rowSelected = table.getElementsByTagName('tr')[rowId];
                info.innerHTML =  rowSelected.cells[3].innerHTML;
            }
        })
        var rows = table.getElementsByTagName('tr');
        if(rows.length > 1){ //display first item
            info.innerHTML = rows[1].cells[3].innerHTML;    
        }
    }

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
