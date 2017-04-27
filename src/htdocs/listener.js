function addListener () {
    document.getElementById("statSelect").addEventListener("submit", function(e){
        e.preventDefault();    //stop form from submitting
	alert('it worked');
    });
}

addListener();

