function getBrowserWidth(){
    document.getElementById("widthInput").value = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
}

function getBrowserHeight() {
    document.getElementById("heightInput").value = window.innerHeight || document.documentElement.clientHeight ||document.body.clientHeight;
}

getBrowserWidth();
getBrowserHeight();
