
var objectiveModule = {};


objectiveModule.add_objective = function (wp_name, obj_name) {
    var message = { "workplane": wp_name, "objective": objectives[obj_name] };
    window.location.href = 'skp:add_objective@' + JSON.stringify(message);
};


objectiveModule.get_human_description = function (objective) {
    var description = "Workplane is in compliance when ";
    description += "more than " + objective["goal"] + "% of the space ";
    var good_light = objective["good_light"];
    switch (objective["metric"]) {
        case "DA":
            description += "maintains an illuminance of " + good_light["min"] + "lux or more during, at least, " + objective["good_pixel"];
            description += "% of the occupied time. Occupied time is between " + objective["occupied"]["min"] + " and ";
            description += objective["occupied"]["max"] + " hours, from months " + objective["sim_period"]["min"] + " to " + objective["sim_period"]["max"];
            break;

        case "UDI":
            description += "maintains an illuminance between " + good_light["min"] + "lux and " + good_light["max"] + "lux during, at least, " + objective["good_pixel"];
            description += "% of the occupied time. Occupied time is between " + objective["occupied"]["min"] + " and ";
            description += objective["occupied"]["max"] + " hours, from months " + objective["sim_period"]["min"] + " to " + objective["sim_period"]["max"];
            break;

        case "DF":
            if (good_light["max"]) {
                description += "achieves a Daylight Factor between " + good_light["min"] + "% and " + good_light["max"] + "%";
            } else {
                description += "achieves a Daylight Factor of " + good_light["min"] + "% or more";
            }
            break;

        case "LUX":
            if (good_light["max"]) {
                description += "achieves an illuminance between " + good_light["min"] + "lux and " + good_light["max"] + "lux ";
            } else {
                description += "achieves an illuminance of " + good_light["min"] + "lux or more ";
            }
            description += "under a clear sky at " + objective["hour"] + " hours of " + objective["date"];
            break;
        case "ELUX":
            if (good_light["max"]) {
                description += "achieves an illuminance between " + good_light["min"] + "lux and " + good_light["max"] + "lux ";
                description += "at nighttime but with all the electric lights on."
            } else {
                description += "achieves an illuminance of " + good_light["min"] + "lux or more ";
            }
            description += "at nighttime but with all the electric lights on."
            break;


        default:
            alert("Unkown metric to convert into human language");
    }
    description += ".";
    return description;
};

objectiveModule.create_objective = function () {
    var metric = $("#metric").val();
    var objective = objectiveModule.get_objective_object(metric);
    if (!objective) { return false; }
    objectives[objective["name"]] = objective;
    objectiveModule.update_objectives();
    objectiveModule.add_objective_dialog.dialog("close");
    reportModule.update_objective_summary();
};



objectiveModule.remove_objective = function (workplane, objective) {
    window.location.href = 'skp:remove_objective@' + JSON.stringify({ "workplane": workplane, "objective": objective });
};


objectiveModule.adapt_objective_dialog = function (metric) {
    $("#add_metric_dialog *").show();
    switch (metric) {
        case "DA":
            //maximum illuminance?
            $("label[for='no_maximum']").hide();
            $("#no_maximum").prop("checked", true);
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
            $("#no_maximum").prop("checked", false);
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
            $("#min_lux").val(2);
            break;
        case "LUX":
            $("#ill_goal_field legend").text("Illuminance goal (lux)");
            $("#working_hours_field").hide();
            $("#sim_period_field").hide();
            $("label[for='objective_goal']").text("% of the space meets the illuminance goal");
            $("label[for='metric_threshold']").hide();
            $("#metric_threshold").hide();
            break;
        case "ELUX":
            $("#ill_goal_field legend").text("Illuminance goal (lux)");
            $("#working_hours_field").hide();
            $("#sim_period_field").hide();
            $("label[for='objective_goal']").text("% of the space meets the illuminance goal");
            $("label[for='metric_threshold']").hide();
            $("#metric_threshold").hide();
            $("#day_to_sim_field").hide();
            break;
        default:
            alert("Unkown metric selected!")
    }
    if ($("#no_maximum").is(":checked")) {
        $("#max_lux").attr('disabled', 'disabled');
    } else {
        $("#max_lux").removeAttr('disabled');
    }
};


objectiveModule.isDynamic = function (metric) {
    var dynamic = ["DA", "UDI"];
    var static = ["DF", "LUX"];
    var isDynamic = true;
    if (dynamic.indexOf(metric) < 0) {
        isDynamic = false;
    }
    var isStatic = true;
    if (static.indexOf(metric) < 0) {
        isStatic = false;
    }
    if (!isStatic && !isDynamic) { alert("Metric '" + metric + "' is not Static nor Dynamic"); return }
    return isDynamic
}

/* DATA VALIDATION IS DONE HERE */
objectiveModule.get_objective_object = function (metric) {
    var ret = {};
    ret["name"] = $("#objective_name").val();

    //validate name
    if (ret["name"] == "") { alert("Please asign a valid name for the objective"); return false; }
    if (objectives.hasOwnProperty(ret["name"])) { alert("An objective with such name already exists!"); return false; }

    //good_pixel
    var threshold = parseFloat($("#metric_threshold").val());
    if (threshold > 100 || threshold < 0) {
        alert("Inconsistent parameters.");
        return false;
    }
    ret["good_pixel"] = threshold;

    //validate Good Light range
    var min_lux = parseFloat($("#min_lux").val());
    var max_lux = parseFloat($("#max_lux").val());
    if ($("#no_maximum").is(":checked")) {
        max_lux = false;
    }
    if (max_lux && max_lux <= min_lux) { alert("Please assign a valid goal range. Minimum should be smaller than Maximum"); return false }
    ret["good_light"] = { "min": min_lux, "max": max_lux };

    ret["metric"] = metric;
    ret["goal"] = $("#objective_goal").val();
    ret["dynamic"] = objectiveModule.isDynamic(metric);

    if (ret["dynamic"]) {
        ret["occupied"] = { "min": parseFloat($("#occupied_min").val()), "max": parseFloat($("#occupied_max").val()) };
        ret["sim_period"] = { "min": parseInt($("#sim_min").val()), "max": parseInt($("#sim_max").val()) };

    } else {
        if (metric == "DF") {
            if (min_lux < 0 || min_lux > 100 || max_lux > 100) { alert("Please assign correct Daylight Factor goals (in 0-100% range)"); return false }
            return ret
        } else if (metric == "LUX") {
            ret["date"] = $("#day_to_sim").val();
            ret["hour"] = $("#time_to_sim").val();
        } else if (metric == "ELUX") {
            //nothing to do.
        }
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
    height: 0.8 * $(window).height(),
    width: 0.6 * $(window).width()
});


objectiveModule.update_objectives = function (filter) {
    var list = $("#objectives_list");
    list.html("");
    if (Object.keys(objectives).length == 0) {
        $("<div class='center'><h4>There are no objectives in your model...</h4></div>").appendTo(list);
        return;
    }
    filter = filter.toLowerCase();

    for (var objective in objectives) {
        if (objectives.hasOwnProperty(objective)) {
            if (objective.toLowerCase().indexOf(filter) >= 0) {//filter by objective name  
                var new_row = $("<li>" + objective + "</li>");
                new_row.draggable({
                    appendTo: "body",
                    helper: "clone"
                });
                
                list.append(new_row)
            }
        }
    }
}


$("#objectives_filter").keyup(function () {
    objectiveModule.update_objectives(this.value);
});


objectiveModule.get_new_row_for_workplane = function (workplane, objective) {
    var row = $("<tr></tr>");
    var name_column = $("<td>" + objective + "</td>");
    row.append(name_column);

    var actions_column = $("<td></td>");
    var delete_button = $("<span name='" + workplane + "' title='" + objective + "' class='ui-icon ui-icon-trash del-objective'></span>")
    delete_button.on("click", function () {
        var wp = $(this).attr("name");
        var obj = $(this).parent().siblings("td").text();        
        objectiveModule.remove_objective(wp, obj);
    });
    actions_column.append(delete_button);
    row.append(actions_column);
    return row;
}

objectiveModule.update_workplanes = function (filter) {
    var ul = $("#workplane_objectives"); ul.html("");

    if (Object.keys(workplanes).length == 0) {
        $("<div class='center'><h4>There are no workplanes in your model...</h4></div>").appendTo(ul);
        return;
    }
    filter = filter.toLowerCase();


    for (var wp_name in workplanes) {
        if (workplanes.hasOwnProperty(wp_name)) {
            if (wp_name.toLowerCase().indexOf(filter) >= 0) {//filter by workplane name  
                //first, create the h3 header
                var li = $("<li></li>");
                var title = $("<h1></h1>");
                title.text(wp_name);
                li.append(title);

                li.droppable({
                    hoverClass: "hover",
                    accept: ":not(.ui-sortable-helper)",
                    drop: function (event, ui) {
                        if ("LI" != ui.draggable.prop("tagName")) { return };

                        var wp_name = $(this).find("h1").text();

                        var table_name = wp_name.replace(/\s/g, "_") + "_objectives";
                        var objective = ui.draggable.text();
                        //check if workplane already has the objective
                        if (workplanes[wp_name].indexOf(objective) >= 0) {
                            alert("That workplane has already been assigned that objective!")
                            return;
                        }
                        //add the objective visually to the UI
                        var new_row = objectiveModule.get_new_row_for_workplane(wp_name, objective);
                        var table = $("#" + table_name);
                        if (table.length == 0) { // if the table does not exist
                            $(this).find("div").remove(); //remove the "drop here" tag
                            table = $("<table id='" + table_name + "'></table>"); // Create it 
                            table.appendTo($(this)); //append it
                        }
                        //now we are sure it exists
                        new_row.appendTo(table);

                        //register the objective in the data structure                    
                        workplanes[wp_name].push(objective);

                        //pass the information to SketchUp
                        objectiveModule.add_objective(wp_name,objective);                                                           
                    }
                });
                ul.append(li);

                // Fill with objectives
                var objectives = workplanes[wp_name];
                if (objectives.length == 0) {
                    li.append($("<div>Drop objectives here</div>"))
                    li.addClass("empty");
                } else {
                    var table = $("<table id='" + wp_name.replace(/\s/g, "_") + "_objectives'>");
                    for (var i = 0; i < objectives.length; i++) {
                        var row = objectiveModule.get_new_row_for_workplane(wp_name, objectives[i]);
                        table.append(row);
                    }
                    li.append(table);
                }

            }
        }
    }


}


$("#workplane_objectives_filter").keyup(function () {
    objectiveModule.update_workplanes(this.value);
});

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
        $("#max_lux").attr('disabled', 'disabled');
    } else {
        this.value = "false";
        $("#max_lux").removeAttr('disabled');
    }
});

objectiveModule.adapt_objective_dialog("DA");



$(".resizable1").resizable(
    {
        autoHide: true,
        handles: 'e',
        resize: function (e, ui) {
            var parent = ui.element.parent();
            var remainingSpace = parent.width() - ui.element.outerWidth(),
                divTwo = ui.element.next(),
                divTwoWidth = (remainingSpace - divTwo.outerWidth() + divTwo.width()) / parent.width() * 98 + "%";
            divTwo.width(divTwoWidth);
        },
        stop: function (e, ui) {
            var parent = ui.element.parent();
            ui.element.css(
                {
                    width: ui.element.width() / parent.width() * 100 + "%",
                });
        }
    });
