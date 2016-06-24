
var objectiveModule = {};


objectiveModule.add_objective = function() {
    var metric = $("#metric").val();
    var selected_workplane = $("#workplane_to_add_objective").val();
    var objective = objectiveModule.get_objective_text(metric);     
    window.location.href = 'skp:add_objective@'+JSON.stringify({"workplane":selected_workplane, "objective":objective});    
    objectiveModule.add_objective_dialog.dialog("close");
  
};

objectiveModule.remove_objective = function(workplane,objective) {          
    window.location.href = 'skp:remove_objective@'+JSON.stringify({"workplane":workplane, "objective":objective});        
};


objectiveModule.adapt_objective_dialog = function(metric) {
    $("#add_metric_dialog *").show();
    switch (metric) {
        case "DA":
            $("label[for='max_lux']").hide();
            $("#max_lux").hide();
            $("#day_to_sim_field").hide();
            $("label[for='spatial_threshold']").text("% of the space meets illuminance goals for ");
            $("label[for='metric_threshold']").text("% of the time or more");
            break;
        case "UDI":
            $("#day_to_sim_field").hide();
            $("label[for='spatial_threshold']").text("% of the space meets illuminance goals for ");
            $("label[for='metric_threshold']").text("% of the time or more");
            break;
        case "DF":
            $("#day_to_sim_field").hide();
            $("#working_hours_field").hide();
            $("#sim_period_field").hide();
            $("#ill_goal_field").hide();
            $("label[for='spatial_threshold']").text("% of the space has a Daylight Factor of ");
            $("label[for='metric_threshold']").text("% or more");
            break;
        case "Lux":
            $("#working_hours_field").hide();
            $("#sim_period_field").hide();
            $("label[for='spatial_threshold']").text("% of the space meets illuminance goals");
            $("label[for='metric_threshold']").hide();
            $("#metric_threshold").hide();
            break;
        default:
            alert("Unkown metric selected!")
    }
};

objectiveModule.get_objective_text = function(metric) {
    var del = " | "
    var month_ini = $("#month_ini").val();
    var month_end = $("#month_end").val();
    var period = "From month " + month_ini + " to month " + month_end;
    if (month_ini == 1 && month_end == 12) { period = "Whole year"; }
    var workday = "Working from " + $("#early").val() + " to " + $("#late").val();
    var goal = $("#spatial_threshold").val()+"%";
    switch (metric) {
        case "DA":
            ret = ["DA(" + $("#min_lux").val() + "lux," + $("#metric_threshold").val() + "%)"];
            break;
        case "UDI":
            ret = ["UDI(" + $("#min_lux").val() + "-" + $("#max_lux").val() + "lux," + $("#metric_threshold").val() + "%)"];
            break;
        case "DF":
            ret = ["DF(" + $("#metric_threshold").val() + "%)"];
            ret.push(goal);
            return ret.join("");
        case "Lux":
            ret = ["LUX(" + $("#min_lux").val() + "-" + $("#max_lux").val() + "lux)"];
            ret.push($("#time_to_sim").val() + "hrs of " + $("#day_to_sim").val());
            ret.push(goal);
            return ret.join(del);
        default:
            alert("Unkown metric selected!");
    }
    ret.push(period);
    ret.push(workday);
    ret.push(goal);
    return ret.join(del);
}

objectiveModule.add_objective_dialog = $("#add_metric_dialog").dialog({
    autoOpen: false,
    modal: true,
    buttons: {
        "Add objective": objectiveModule.add_objective,
        Cancel: function () {
            objectiveModule.add_objective_dialog.dialog("close");
        }
    },
    height: 0.9*$(window).height(), 
    width: 0.6*$(window).width()
});

objectiveModule.update_objectives = function() {
    var accordion = $("#workplane_objectives"); accordion.html("");
    var html = ""
    
    for (var wp_name in workplanes) {
        if (workplanes.hasOwnProperty(wp_name)) {
            //add the objectives and workplanes to the accordion                      
            html = html + "<h3>" + wp_name + "</h3>"
                + "<div>"
                + "<table id='" + wp_name.replace(/\s/g, "_") + "_objectives' class='selectable'><tr><td>Objectives</td><td></td></tr>";           

            var objectives = workplanes[wp_name];
            for (var i = 0; i < objectives.length; i++) {
                html = html + "<tr><td>" + objectives[i] + "</td><td><span name='"+wp_name+"' title='"+objectives[i]+"' class='ui-icon ui-icon-trash del-objective'></span></td></tr>"
            }

            html = html + "</table>"
                + "</div>";
        }
    }

    accordion.html(html);
    $("span.del-objective").on("click", function () {
        var workplane = $(this).attr("name");
        var objective = $(this).parent().siblings("td").text();
        objectiveModule.remove_objective(workplane,objective);
    });
    accordion.accordion("refresh");
}

objectiveModule.update_dialog = function() {
    var select = $("#workplane_to_add_objective"); select.html("<option value='all'>All</option>");
    for (var wp_name in workplanes) {
        if (workplanes.hasOwnProperty(wp_name)) {
            // add it to the select within the dialog.                               
            select.append($('<option>', {
                value: wp_name,
                text: wp_name
            }));
        }
    }

    objectiveModule.update_objectives();
}

objectiveModule.get_workplane_objectives = function() {
    var json = JSON.stringify(workplanes);
    console.log(json);
};

$("#metric").on("change", function () {
    objectiveModule.adapt_objective_dialog(this.value);
});

$("#add_objective_to_worplane").button().on("click", function () {
    objectiveModule.add_objective_dialog.dialog("open");
});

$("#day_to_sim").datepicker();

objectiveModule.update_dialog();
objectiveModule.adapt_objective_dialog("DA");
