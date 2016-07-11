//Daylight simulation
$("#set_low_static").on("click", function () { $("#static_parameters").val("-ab 4 -ad 1000 -lw 1e-3")});
$("#set_med_static").on("click", function () { $("#static_parameters").val("-ab 7 -ad 3000 -lw 1e-4")});
$("#set_high_static").on("click", function () { $("#static_parameters").val("-ab 9 -ad 9999 -lw 1e-5")});

$("#set_low_dynamic").on("click", function () { $("#dynamic_parameters").val("-ab 4 -ad 1000 -lw 1e-3") });
$("#set_med_dynamic").on("click", function () { $("#dynamic_parameters").val("-ab 7 -ad 3000 -lw 1e-4") });
$("#set_high_dynamic").on("click", function () { $("#dynamic_parameters").val("-ab 9 -ad 9999 -lw 1e-5") });

$("#set_low_tdd").on("click", function () {
    $("#tdd_daylight_parameters").val("-ab 3 -ad 512 -lw 1e-3");
    $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
    $("#tdd_view_parameters").val("-ab 3 -ad 512 -lw 1e-3");
});
$("#set_med_tdd").on("click", function () {
    $("#tdd_daylight_parameters").val("-ab 3 -ad 512 -lw 1e-3");
    $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
    $("#tdd_view_parameters").val("-ab 3 -ad 512 -lw 1e-3");
});
$("#set_high_tdd").on("click", function () {
    $("#tdd_daylight_parameters").val("-ab 3 -ad 1000 -lw 1e-3");
    $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
    $("#tdd_view_parameters").val("-ab 6 -ad 5512 -lw 1e-5");
});

$("#simulate_button").on("click", function () { 
    var options = {};   
    $("#simulation_options *").each(function () {
        var title = $(this).attr("title");
        if(title && title=="option"){
            if($(this).is("input[type=checkbox]")){
                var id = $(this).attr("id");
                var state = $('#' + id).is(":checked");
                options[id]=state;
            }else{
                options[$(this).attr("id")] = $(this).val();
            }
            
        }
    });    
    window.location.href = 'skp:calculate@' + JSON.stringify(options);
});
