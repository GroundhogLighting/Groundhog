// THIS IS JAVASCRIPT

function checkSidenavLocation(){
    var win_width = $(window).width();
    var display_width = $("div.display").width();
    var sidenav_width = $("#sidenav").width();
    if(win_width < 700){
        hideSidenav();       
        $("div.display").width(win_width);     
    }else{
        showSidenav();
        $("div.display").width(win_width - sidenav_width);
    }

}

function showSidenav() {
    var sidenav = $("#sidenav");
    var side_w = sidenav.width();
    sidenav.offset({ top: 0, left: 0 });
    $("div.display").offset({ top: 0, left: side_w });
}

function hideSidenav() {
    var sidenav = $("#sidenav");
    var side_w = sidenav.width();
    sidenav.offset({ top: 0, left: -side_w });
    $("div.display").offset({ top: 0, left: 0 });
}



/* HIDE ALL BUT THE SELECTED DISPLAY */
function selectDisplay(dest) {
    $("div.display").hide();
    $("div" + dest).show(50);
}




$('input[type=checkbox]').on("change", function () {
    if (this.checked) {
        this.value = "true";
    } else {
        this.value = "false";
    }
});

$("#sidenav p").on("click", function () {
    $("#sidenav p").removeClass("selected");
    $(this).addClass("selected");
    selectDisplay($(this).attr('href'));
    showSidenav();
});




/// CALL INITIAL FUNCTIONS

// Add the Editable tag to those inputs that require it
$("td input").each(function(){
    $(this).parent().append("<i class='material-icons'>mode_edit</i>");
});

selectDisplay($("#sidenav p.selected").attr('href'));
showSidenav();


$(".dialog").hide();


$( window ).resize(function() {
    checkSidenavLocation();
});

checkSidenavLocation();