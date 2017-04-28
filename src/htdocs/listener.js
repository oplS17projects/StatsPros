function addListener () {
    document.getElementById("statSelect").addEventListener("submit", function(e) {
	var i = 0, dropdown = document.getElementById("dropdown");
	
        e.preventDefault();    //stop form from submitting
	for(i; i < dropdown.length; i++) {
	    if(dropdown[i].value === dropdown.value) {
		document.getElementById(dropdown[i].value).style.display = "";
	    } else {
		document.getElementById(dropdown[i].value).style.display = "none";		
	    }
	}
    });
}

addListener();
