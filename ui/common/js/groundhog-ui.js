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
    //sidenav.offset({ top: 0, left: 0 });
    $("div.display").offset({ top: 0, left: side_w });
}

function hideSidenav() {
    //var sidenav = $("#sidenav");
    //var side_w = sidenav.width();
    //sidenav.offset({ top: 0, left: -side_w });
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


// DIALOGS
var openDialog = function(dialogId){    
    $("#"+dialogId+"_wrap.dialog_wrap").offset({ top: 0, left: 0 });    
}

var closeDialog = function(dialogId){
    var win_width = $(window).width();
    $("#"+dialogId+"_wrap.dialog_wrap").offset({ top: 0, left: win_width*1.1 });
}

$(".dialog").each(function(){
    var dialog = $(this);
    var id = dialog.attr("id");
    var wrap = $("<div class='dialog_wrap' id='"+id+"_wrap'></div>");


    dialog.wrap(wrap);    
    wrap.css("left","100vw");
    
    dialog.prepend("<h1 class='dialog_header'>"+dialog.attr("title")+"</h1>");  
    var cancelButton = $("<button class='mainbutton cancelbutton'>Cancel</button>");
    var acceptButton = $("<button class='primary mainbutton'>Accept</button>");
    
    var buttonContainer = $("<fieldset></fieldset>");
    dialog.append(buttonContainer);

    cancelButton.on("click",function(){
        closeDialog(id);
    });

    acceptButton.on("click",function(){
        closeDialog(id);
    });      

    buttonContainer.append(cancelButton);
    buttonContainer.append(acceptButton);

    closeDialog(id);
});    

setOnSubmit = function(dialog,f){    
    dialog.find("button.primary").on("click",f);
}

setOnCancel = function(dialog,f){
    dialog.find("button.cancelbutton").on("click",f);
}



/// CALL INITIAL FUNCTIONS

// Add the Editable tag to those inputs that require it
$("td input").each(function(){
    $(this).parent().append("<i class='material-icons'>mode_edit</i>");
});

selectDisplay($("#sidenav p.selected").attr('href'));
showSidenav();




$( window ).resize(function() {
    checkSidenavLocation();
});

checkSidenavLocation();