
var objectiveModule = {};



objectiveModule.metrics = {
  "DA" :  {
    "name": "Daylight Autonomy",
    "requirements" : {"good_pixel": 50, "good_light": {"min": 300, "max":false}, "goal": 50, "occupied" : {"min": 8, "max" : 18}, "sim_period":{"min":1, "max": 12 } }, //"date"
    "dynamic" : true,
    "good_light_legend" : "Illuminance goal (lux)",
    "human_language" : "Workplane is in compliance when at least %goal%% of the space achieves an illuminance of %good_light_min%lux or more for a minimum of %good_pixel%% of the occupied time by daylight only. Occupied time is between %occupied_min% and %occupied_max% hours, from months %sim_period_min% to %sim_period_max%.",
  },
  "UDI" :  {
    "name": "Useful Daylight Illuminance",
    "requirements" : {"good_pixel": 50, "good_light": {"min": 300, "max":3000}, "goal": 50, "occupied" : {"min": 8, "max" : 18}, "sim_period":{"min":1, "max": 12 } }, //"date"
    "dynamic" : true,
    "human_language" : "Workplane is in compliance when at least %goal%% of the space achieves an illuminance between %good_light_min%lux and %good_light_max%lux during for a minimum of %good_pixel%% of the occupied time by daylight only. Occupied time is between %occupied_min% and %occupied_max% hours, from months %sim_period_min% to %sim_period_max%.",
    "good_light_legend" : "Illuminance goal (lux)"
  },
  "DF" :  {
    "name": "Daylight Factor",
    "requirements" : {"good_light": {"min": 2, "max": 10}, "goal": 50 }, //"date"
    "dynamic" : false,
    "human_language" : "Workplane is in compliance when at least %goal%% of the space presents a Daylight Factor between %good_light_min%% and %good_light_max%%.",
    "good_light_legend" : "Daylight Factor goal (%)"
  },
  "LUX" :  {
    "name": "Illuminance under clear sky",
    "requirements" : {"good_light": {"min": 300, "max":2000}, "goal": 50, "date" : {"date": "", "hour": 12}},
    "dynamic" : false,
    "human_language" : "Workplane is in compliance when at least %goal%% of the space presents an illuminance between %good_light_min%lux and %good_light_max%lux under a clear sky at %date_hour% hours on %date_date%.",
    "good_light_legend" : "Illuminance goal (lux)"
  }

};




objectiveModule.add_objective = function (wp_name, obj_name) {
  var message = { "workplane": wp_name, "objective": objectives[obj_name] };
  window.location.href = 'skp:add_objective@' + JSON.stringify(message);
};



objectiveModule.get_human_description = function (objective) {
  var metric = objective["metric"];
  var description = objectiveModule.metrics[metric]["human_language"];
  var requirements = objectiveModule.metrics[metric]["requirements"];

  //replace the data in the description
  for (var item_name in requirements) {
    if (requirements.hasOwnProperty(item_name)) {
      var item = requirements[item_name];
      // get values
      if (item !== null && typeof item === 'object'){
        for (var sub_item_name in item) {
          if (item.hasOwnProperty(sub_item_name)) {
            description = description.replaceAll("%"+item_name+"_"+sub_item_name+"%",$("#objective_"+item_name+"_"+sub_item_name).val());
          }
        }
      }else{
        description = description.replaceAll("%"+item_name+"%", $("#objective_"+item_name).val());
      }
    }
  }
  return description;
};

objectiveModule.update_human_description = function(){
  //change human description
  var metric = $("#metric").val();
  $("#objective_human_description").text(objectiveModule.get_human_description(objectiveModule.get_objective_object(metric).object));
}

objectiveModule.create_objective = function () {
  var metric = $("#metric").val();
  var objective = objectiveModule.get_objective_object(metric);
  if (!objective.success) { alert(objective.error); return false; }
  objective = objective.object
  var name = objective["name"];
  if(objectives.hasOwnProperty(name)){
      var r = confirm("This objective already exists. Do you want to replace it?");
      if(!r){
        return false;
      }
  }else if(name == ""){
      alert("Please insert a valid name for the objective");
      return false;
  }
  objectives[name] = objective;
  objectiveModule.update_objectives("");
  objectiveModule.add_objective_dialog.dialog("close");
  reportModule.update_objective_summary();
  window.location.href = 'skp:create_objective@' + JSON.stringify(objective);
};



objectiveModule.remove_objective = function (workplane, objective) {
  window.location.href = 'skp:remove_objective@' + JSON.stringify({ "workplane": workplane, "objective": objective });
};




objectiveModule.adapt_objective_dialog = function (metric) {
  var object = objectiveModule.metrics[metric];

  // hide everything
  $("#create_objective_dialog").children().hide();
  $("#objective_good_pixel").hide();
  $("label[for='objective_good_pixel']").hide();

  //show the default things
  $("#objective_name_field").show();
  $("#metric_field").show();
  $("#compliance_field").show();
  $("#human_description").show();

  // Then, show only specific items that are needed.
  for (var item_name in object["requirements"]) {
    if (object["requirements"].hasOwnProperty(item_name)) {
      var item = object["requirements"][item_name];
      //unhide
      $("#objective_"+item_name).show();
      $("label[for='objective_"+item_name+"']").show();

      // set values
      if (item !== null && typeof item === 'object'){
        for (var sub_item_name in item) {
          if (item.hasOwnProperty(sub_item_name)) {
            var sub_item = item[sub_item_name];
            $("#objective_"+item_name+"_"+sub_item_name).val(sub_item);
          }
        }
      }else{
        $("#objective_"+item_name).val(object["requirements"][item_name]);
      }
    }
  }
  //change legend
  $("#objective_good_light_legend").text(object["good_light_legend"]);
  objectiveModule.update_human_description();
};


/* DATA VALIDATION IS DONE HERE */
objectiveModule.get_objective_object = function (metric) {
  //get the requirements
  var ret = {};
  ret["name"] = $.trim($("#objective_name").val());
  ret["metric"] = metric;
  var object = objectiveModule.metrics[metric];
  ret["dynamic"] = object["dynamic"];

  //retrieve corresponding data
  for (var item_name in object["requirements"]) {
    if (object["requirements"].hasOwnProperty(item_name)) {
      var item = object["requirements"][item_name];
      // get values
      if (item !== null && typeof item === 'object'){
        ret[item_name]={};
        for (var sub_item_name in item) {
          if (item.hasOwnProperty(sub_item_name)) {
            var input = $("#objective_"+item_name+"_"+sub_item_name);
            ret[item_name][sub_item_name] = input.val();
            if(input.attr("type")==="number"){
              ret[item_name][sub_item_name] = parseFloat(ret[item_name][sub_item_name]);
            }
          }
        }
      }else{
        ret[item_name] = parseFloat($("#objective_"+item_name).val());
      }
    }
  }
  //change legend
  $("#objective_good_light_legend").text(object["good_light_legend"]);
  return {success: true, object: ret};
}


objectiveModule.add_objective_dialog = $("#create_objective_dialog").dialog({
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
        var new_row = $("<tr></tr>");
        var drag = $(("<td name='"+objective+"'>" + objective +"</td>"));
        new_row.append(drag); //
        var action_column = $("<td></td>");
        var delete_button = $("<span name=\"" + objective + "\" class='ui-icon ui-icon-trash del-material'></span>")
        var edit_button = $("<span name=\"" + objective + "\" class='ui-icon ui-icon-pencil edit-material'></span>")
        delete_button.on("click", function () {
          var objective_name = $(this).attr("name");
          window.location.href = 'skp:delete_objective@' +objective_name;
        });
        edit_button.on("click", function () {
          var objective_name = $(this).attr("name");
          objectiveModule.editObjective(objective_name);
        });
        new_row.append(action_column);
        action_column.append(edit_button);
        action_column.append(delete_button);
        drag.draggable({
          appendTo: "body",
          helper: "clone"
        });

        list.append(new_row)
      }
    }
  }
}

objectiveModule.editObjective = function(objective_name){
  $("#objective_name").prop("disabled",true);
  var obj = objectives[objective_name];
  var object = objectiveModule.metrics[obj["metric"]];
  objectiveModule.adapt_objective_dialog(obj["metric"]);

  $("#metric").val(obj["metric"]);
  $("#objective_name").val(obj["name"]);

  for (var item_name in object["requirements"]) {
    if (object["requirements"].hasOwnProperty(item_name)) {
      var item = object["requirements"][item_name];
      // get values
      if (item !== null && typeof item === 'object'){
        for (var sub_item_name in item) {
          if (item.hasOwnProperty(sub_item_name)) {
            $("#objective_"+item_name+"_"+sub_item_name).val(obj[item_name][sub_item_name]);
          }
        }
      }else{
        $("#objective_"+item_name).val(obj[item_name]);
      }
    }
  }
  objectiveModule.add_objective_dialog.dialog("open");
};

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
            if ("TD" != ui.draggable.prop("tagName")) { alert(ui.draggable.prop("tagName"));return };

            var wp_name = $(this).find("h1").text();

            var table_name = utilities.fixName(wp_name) + "_objectives";
            var objective = ui.draggable.attr("name");
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
          var table = $("<table id='" + utilities.fixName(wp_name) + "_objectives'>");
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

$("#create_objective_button").button().on("click", function () {
  $("#objective_name").removeAttr("disabled");
  objectiveModule.add_objective_dialog.dialog("open");
});

$("#objective_date_date").datepicker();


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


    for (var metric in objectiveModule.metrics) {
      if (objectiveModule.metrics.hasOwnProperty(metric)) {
        $('#metric').append($('<option>', {
          value: metric,
          text : objectiveModule.metrics[metric]["name"]
        }));
      }
    }


    var first = "";
    for (item in objectiveModule.metrics){
      first = item;
      break;
    }
    objectiveModule.adapt_objective_dialog(first);

    $("#create_objective_dialog input").change(function(){
      objectiveModule.update_human_description();
    });
