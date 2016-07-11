
var objectiveModule = {};


objectiveModule.add_objective = function(wp_name,obj_name) {    
    var message={"workplane": wp_name, "objective":objectives[obj_name]};    
    window.location.href = 'skp:add_objective@'+JSON.stringify(message);        
};




objectiveModule.create_objective = function() {
    var metric = $("#metric").val();
    var selected_workplane = $("#workplane_to_add_objective").val();
    var objective = objectiveModule.get_objective_object(metric);    
    if(!objective){ return false;}            
    objectives[objective["name"]]=objective;    
    objectiveModule.update_objectives();
    objectiveModule.add_objective_dialog.dialog("close");
};



objectiveModule.remove_objective = function(workplane,objective) {          
    window.location.href = 'skp:remove_objective@'+JSON.stringify({"workplane":workplane, "objective":objective});        
};


objectiveModule.adapt_objective_dialog = function(metric) {
    $("#add_metric_dialog *").show();
    switch (metric) {
        case "DA":
            //maximum illuminance?
            $("label[for='no_maximum']").hide();
            $("#no_maximum").prop("checked",true);
            $("#no_maximum").hide();        

            //units for goals
            $("#ill_goal_field legend").text("Illuminance goal (lux)");

            //specific date?                
            $("#day_to_sim_field").hide();
            
            //human language explanation
            $("label[for='objective_goal']").text("% of the space meets illuminance goals for ");
            $("label[for='metric_threshold']").text("% of the occupied time or more");
            $("#min_lux").val(300);            
            break;
        case "UDI":
            //maximum illuminance?
            $("label[for='no_maximum']").hide();
            $("#no_maximum").prop("checked",false);
            $("#no_maximum").hide();        

            //units for goals
            $("#ill_goal_field legend").text("Illuminance goal (lux)");

            //specific date?                
            $("#day_to_sim_field").hide();
            
            //human language explanation
            $("label[for='objective_goal']").text("% of the space meets illuminance goals for ");
            $("label[for='metric_threshold']").text("% of the occupied time or more");

            $("#min_lux").val(300);
            $("#max_lux").val(3000);
            break;
        case "DF":
            $("#day_to_sim_field").hide();
            $("#working_hours_field").hide();
            $("#sim_period_field").hide();
            $("#ill_goal_field legend").text("Daylight factor goal (%)");
            $("label[for='objective_goal']").text("% of the space meets the Daylight Factor goal");
            $("label[for='metric_threshold']").hide();
            $("#metric_threshold").hide();
            $("#min_lux").val(50);
            break;
        case "LUX":
            $("#ill_goal_field legend").text("Illuminance goal (lux)");
            $("#working_hours_field").hide();
            $("#sim_period_field").hide();
            $("label[for='objective_goal']").text("% of the space meets the illuminance goal");
            $("label[for='metric_threshold']").hide();
            $("#metric_threshold").hide();
            break;
        default:
            alert("Unkown metric selected!")
    }
    if($("#no_maximum").is(":checked")){ 
        $("#max_lux").attr('disabled','disabled');
    }else{
        $("#max_lux").removeAttr('disabled');
    }
};


objectiveModule.isDynamic = function(metric){
    var dynamic = ["DA", "UDI"];
    var static = ["DF", "LUX"];
    var isDynamic = true;
    if(dynamic.indexOf(metric)<0){
        isDynamic = false;
    }
    var isStatic = true;
    if(static.indexOf(metric)<0){
        isStatic = false;
    }
    if(!isStatic && !isDynamic){ alert("Metric '"+metric+"' is not Static nor Dynamic"); return}
    return isDynamic 
}

/* DATA VALIDATION IS DONE HERE */
objectiveModule.get_objective_object = function(metric){
    var ret = {}; 
    ret["name"]=$("#objective_name").val();    

    //validate name
    if(ret["name"]==""){alert("Please asign a valid name for the objective"); return false;}
    if(objectives.hasOwnProperty(ret["name"])){alert("An objective with such name already exists!");return false;}

    //good_pixel
    var threshold = parseFloat($("#metric_threshold").val());
    if(threshold > 100 || threshold < 0){
        alert("Inconsistent parameters.");
        return false;
    }
    ret["good_pixel"]=threshold;

    //validate Good Light range
    var min_lux = parseFloat($("#min_lux").val());
    var max_lux = parseFloat($("#max_lux").val());     
    if($("#no_maximum").is(":checked")){ 
        max_lux = false; 
    }
    if(max_lux && max_lux <= min_lux){alert("Please assign a valid goal range. Minimum should be smaller than Maximum"); return false}
    ret["good_light"]={"min": min_lux, "max":max_lux};

    ret["metric"]=metric;
    ret["goal"]=$("#objective_goal").val();    
    ret["dynamic"]=objectiveModule.isDynamic(metric);
    
    if(ret["dynamic"]){
        ret["occupied"]={"min": parseFloat($("#occupied_min").val()), "max":parseFloat($("#occupied_max").val())};
        ret["sim_period"]={"min": parseInt($("#sim_min").val()), "max":parseInt($("#sim_max").val())};
        
    }else{
        if(metric == "DF"){
            if(min_lux < 0 || min_lux > 100 || max_lux > 100){alert("Please assign correct Daylight Factor goals (in 0-100% range)"); return false}
            return ret
        }

        ret["date"]=$("#day_to_sim").val();
        ret["hour"]=$("#time_to_sim").val();
    }
    return ret
}


objectiveModule.add_objective_dialog = $("#add_metric_dialog").dialog({
    autoOpen: false,
    modal: true,
    buttons: {
        "Create objective": objectiveModule.create_objective,
        Cancel: function () {
            objectiveModule.add_objective_dialog.dialog("close");
        }
    },
    height: 0.8*$(window).height(), 
    width: 0.6*$(window).width()
});


objectiveModule.update_objectives = function() {
    var table = $("#objectives_table"); table.html("<tr><td>Objectives</td></tr>");    
    for(var objective in objectives){
        if (objectives.hasOwnProperty(objective)) {
            var new_row = $("<tr><td>"+objective+"</td></tr>");              
            new_row.draggable({
                appendTo: "body",
                helper: "clone"
            });
            table.append(new_row)          
        }
    }    
}

objectiveModule.get_new_row_for_workplane = function(workplane,objective){
    var row = $("<tr></tr>");
    var name_column = $("<td>" + objective + "</td>");
    row.append(name_column);

    var actions_column = $("<td></td>");
    var delete_button = $("<span name='"+workplane+"' title='"+objective+"' class='ui-icon ui-icon-trash del-objective'></span>")                
    delete_button.on("click", function () {        
        var wp = $(this).attr("name");
        var obj = $(this).parent().siblings("td").text();
        objectiveModule.remove_objective(wp,obj);
    });
    actions_column.append(delete_button);
    row.append(actions_column);
    return row;
}

objectiveModule.update_workplanes = function() {
    var accordion = $("#workplane_objectives"); accordion.html("");
    
    if(Object.keys(workplanes).length == 0){
        $("<div class='center'><h4>There are no workplanes in your model...</h4></div>").appendTo(accordion);
        return;
    }

    for (var wp_name in workplanes) {
        if (workplanes.hasOwnProperty(wp_name)) {

             //first, create the h3 header
            var header = $("<h3>" + wp_name + "</h3>"); 
            header.droppable({
                // activeClass: "ui-state-default",
                hoverClass: "ui-state-hover",
                accept: ":not(.ui-sortable-helper)",
                drop: function( event, ui ) {                                       
                    var wp_name = $(this).text();
                    var table_name = wp_name.replace(/\s/g, "_") + "_objectives";
                    var objective = ui.draggable.text();  
                    //check if workplane already has the objective
                     if(workplanes[wp_name].indexOf(objective) >=0){
                         alert("That workplane has already been assigned that objective!")
                         return;
                     }           
                    //add the objective visually to the UI
                    var new_row = objectiveModule.get_new_row_for_workplane(wp_name,objective);
                    new_row.appendTo( $("#"+table_name) );

                    //register the objective in the data structure                    
                    workplanes[wp_name].push(objective);                                                                                

                    //pass the information to SketchUp
                    objectiveModule.add_objective(wp_name,objective);                                                           
                }
            }); 
            accordion.append(header);

            var div = $("<div></div>"); 
            div.droppable({
                // activeClass: "ui-state-default",
                hoverClass: "ui-state-hover",
                accept: ":not(.ui-sortable-helper)",
                drop: function( event, ui ) {
                    var siblings = $(this).siblings("h3");
                    var table = $(this).children("table");
                    var table_id = table.attr("id");
                    
                    //find the workplane name.
                    var wp_name = false;                    
                    for(var i=0; i<siblings.length; i++){
                        wp_name = siblings[i].textContent;
                        if(wp_name.replace(/\s/g, "_") + "_objectives" == table_id){
                            break;
                        }
                        
                    } 

                    var objective = ui.draggable.text();

                    //check if workplane already has the objective
                     if(workplanes[wp_name].indexOf(objective) >=0){
                         alert("That workplane has already been assigned that objective!")
                         return;
                     }          

                    //add the objective visually to the UI
                    var new_row = objectiveModule.get_new_row_for_workplane(wp_name,objective);
                    new_row.appendTo( $(this).children("table") );

                    //register the objective in the data structure                    
                    workplanes[wp_name].push(objective);                                                                                

                    //pass the information to SketchUp
                    objectiveModule.add_objective(wp_name,objective);
                    
                }
            });                        
            accordion.append(div);
            
            var table = $("<table id='" + wp_name.replace(/\s/g, "_") + "_objectives' class='selectable'><tr><td>Objectives</td><td></td></tr>");                              
            div.append(table);       

            var objectives = workplanes[wp_name];
            for (var i = 0; i < objectives.length; i++) {
                var row = objectiveModule.get_new_row_for_workplane(wp_name,objectives[i]);
                table.append(row);
            }               
        }
    }

    
    accordion.accordion("refresh");
}


$("#metric").on("change", function () {
    objectiveModule.adapt_objective_dialog(this.value);
});

$("#add_objective_to_worplane").button().on("click", function () {
    objectiveModule.add_objective_dialog.dialog("open");
});

$("#day_to_sim").datepicker();

$('#no_maximum').on("change", function () {
        if (this.checked) {
            this.value = "true";
            $("#max_lux").attr('disabled','disabled');           
        } else {
            this.value = "false";
            $("#max_lux").removeAttr('disabled');
        }        
    });

objectiveModule.adapt_objective_dialog("DA");







