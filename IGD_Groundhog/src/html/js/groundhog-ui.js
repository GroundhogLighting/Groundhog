
    function showSidenav() {
        var sidenav = $("#sidenav");
        var side_w = sidenav.width();
        sidenav.offset({ top: 0, left: 0 });
        $("div.display").offset({ top: 0, left: side_w });
        $("div.fixed_toolbar").offset({ top: 0, left: side_w-1 });
    }

    function hideSidenav() {
        var sidenav = $("#sidenav");
        var side_w = sidenav.width();
        sidenav.offset({ top: 0, left: -side_w });
        $("div.display").offset({ top: 0, left: 0 });
        $("div.fixed_toolbar").offset({ top: 0, left: 0 });
    }

    /* HIDE ALL BUT THE SELECTED DISPLAY */
    function selectDisplay(dest) {
        $("div.display").hide();
        $("div" + dest).show();
    }

    $('input[type=checkbox]').on("change", function () {
        if (this.checked) {
            this.value = "true";
        } else {
            this.value = "false";
        }
    });

    var tabs = $("#sidenav p")
    tabs.button();
    tabs.on("click", function () {
        $("#sidenav p").removeClass("selected");
        $(this).toggleClass("selected");
        selectDisplay($(this).attr('href'));
    });

    showSidenav();
    selectDisplay($("#sidenav p.selected").attr('href'));
    $("button").button();
    $(document).tooltip({
        track:true
    });
    $("div.accordion").accordion({ collapsible: true, heightStyle: 'content'});


