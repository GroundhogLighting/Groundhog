import Utilities = require('../Utilities');
import { Response } from '../../common/core';

//import * as $ from 'jquery' ;

export = class CalculateModule {


    constructor(){        
        //Daylight simulation
        $("#daylight_set_low_parameters").on("click", function () { 
            $("#ray_tracing_parameters").val("-ab 4 -ad 1000 -lw 1e-3")
            $("#elux_ray_tracing_parameters").val("-ab 4 -ad 1000 -lw 1e-3")
            $("#dc_parameters").val("-ab 4 -ad 1000 -lw 1e-3")
        });

        $("#daylight_set_med_parameters").on("click", function () { 
            $("#ray_tracing_parameters").val("-ab 7 -ad 3000 -lw 1e-4")
            $("#elux_ray_tracing_parameters").val("-ab 7 -ad 3000 -lw 1e-4")
            $("#dc_parameters").val("-ab 7 -ad 3000 -lw 1e-4")
        });

        $("#daylight_set_high_parameters").on("click", function () { 
            $("#ray_tracing_parameters").val("-ab 9 -ad 9999 -lw 1e-5")
            $("#elux_ray_tracing_parameters").val("-ab 9 -ad 9999 -lw 1e-5")
            $("#dc_parameters").val("-ab 9 -ad 9999 -lw 1e-5")
        });

        //Electric light simulation
        $("#electric_set_low_parameters").on("click", function () {             
            $("#elux_ray_tracing_parameters").val("-ab 4 -ad 1000 -lw 1e-3");
        });

        $("#electric_set_med_parameters").on("click", function () { 
            $("#elux_ray_tracing_parameters").val("-ab 7 -ad 3000 -lw 1e-4");
        });

        $("#electric_set_high_parameters").on("click", function () { 
            $("#elux_ray_tracing_parameters").val("-ab 9 -ad 9999 -lw 1e-5");
        });


        // TDDs
        $("#tdd_set_low_parameters").on("click", function () {
            $("#tdd_daylight_parameters").val("-ab 3 -ad 512 -lw 1e-3");
            $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
            $("#tdd_view_parameters").val("-ab 3 -ad 512 -lw 1e-3");
        });
        $("#tdd_set_med_parameters").on("click", function () {
            $("#tdd_daylight_parameters").val("-ab 3 -ad 512 -lw 1e-3");
            $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
            $("#tdd_view_parameters").val("-ab 3 -ad 512 -lw 1e-3");
        });
        $("#tdd_set_high_parameters").on("click", function () {
            $("#tdd_daylight_parameters").val("-ab 3 -ad 1000 -lw 1e-3");
            $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
            $("#tdd_view_parameters").val("-ab 6 -ad 5512 -lw 1e-5");
        });

        $("#simulate_button").on("click", function () { 
            let options: any = {};   
            $("#calculate *").each(function () {
                let title = $(this).attr("title");                
                if(title && title === "option"){
                    console.log(title);
                    if($(this).is("input[type=checkbox]")){
                        let id = $(this).attr("id");
                        let state = $('#' + id).is(":checked");
                        options[id]=state;
                    }else{
                        options[$(this).attr("id")] = $(this).val();
                    }
                    
                }
            });
            Utilities.sendAction("calculate",JSON.stringify(options));
        });

    }
}