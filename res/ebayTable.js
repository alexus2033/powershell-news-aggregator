let attached = false;
 
let imageContainer = document.querySelector("#floatingimg");

const followMouse = (event) => {
    var offsetX = 15;
    var offsetY = window.pageYOffset + 12;
    imageContainer.style.left = (event.x+offsetX) + "px";
    imageContainer.style.top = (event.y+offsetY) + "px";
}

function showImage(url) {
  if (!attached) {
    attached = true;
    console.info(url);
    imageContainer.src = url;
    imageContainer.style.display = "flex";
    document.addEventListener("pointermove", followMouse);
  }
}

function hideImage() {
  attached = false;
  imageContainer.style.display = "";
  document.removeEventListener("pointermove", followMouse);
}

window.onload = () => {

    // Find the table
    const dataTable = document.querySelector('table')

    // Give it an ID so it's easier to work with for CSS or subsequent JS
    dataTable.id = 'ebay-table'

    // Move the first row into a THEAD element that PowerShell doesn't add but is necessary for sorting
    const headerRow = dataTable.querySelector('tr:nth-child(1)')
    const thead = document.createElement('thead')
    thead.appendChild(headerRow)

    dataTable.prepend(thead)

    // Mark the named columns as numeric so it sorts correctly
    let numCols = ['FixPrice','Price','Bids']
    let linkCols = ['Article']
    const hd = Array.from(document.querySelectorAll('#ebay-table tr:nth-child(1) th'))
    numCols.forEach(function(item) {
        var col = hd.find(el => el.textContent === item);
        col.setAttribute("data-tsorter", "numeric");
    })
    linkCols.forEach(function(item) {
        var col = hd.find(el => el.textContent === item);
        col.setAttribute("data-tsorter", "link");
    })

    myTimer()
    displayFavs();

    // Update Times every 30 Secs
    setInterval(myTimer, 30000);

    function myTimer() {
        const col2=Array.from(document.querySelectorAll('#ebay-table tr td:nth-child(2)'));
        col2.forEach(function(item){
            if(item.hasAttribute("Timestamp")){
                var ts=item.getAttribute("Timestamp")
            } else {
                var ts=item.innerHTML;
                item.setAttribute("Timestamp",ts)
            }
            var newText=moment(ts,'DD-MMM-YYYY HH:mm a').fromNow();
            item.innerHTML=newText;
        })
    }
}
