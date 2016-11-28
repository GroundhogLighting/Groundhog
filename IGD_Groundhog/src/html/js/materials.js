
//Materials.js
var materialModule = {};

materialModule.processGlass = function(inputs){
  //Verify
  var r = inputs["red"], g = inputs["green"], b = inputs["blue"];

  if( Math.max(r,g,b)>1 || Math.min(r,g,b) < 0){
    return {success: false, error: "Inconsistent color values. Please use values between 0.0 and 1.0"};
  }

  inputs["redT"] = r*1.0895; //(Math.sqrt(0.8402528435+0.0072522239*tau*tau)-0.9166530661)/(0.0036261119*tau);
  inputs["greenT"] = g*1.0895; //(Math.sqrt(0.8402528435+0.0072522239*tau*tau)-0.9166530661)/(0.0036261119*tau);
  inputs["blueT"] = b*1.0895; //(Math.sqrt(0.8402528435+0.0072522239*tau*tau)-0.9166530661)/(0.0036261119*tau);
  inputs["alpha"] =  Math.sqrt(1-(0.265 * r + 0.67 * g + 0.065 * b));
  if(inputs["alpha"] > 0.95){inputs["alpha"] = 0.95};
  return {success: true, object: inputs}
};

materialModule.parseGlass = function(material){
  var rad = material["rad"].split(" ");
  $("#red").  val(rad[6]/1.0895);
  $("#green").val(rad[7]/1.0895);
  $("#blue"). val(rad[8]/1.0895);
};

materialModule.processPlasticAndMetal = function(inputs){
  //Verify
  var r = inputs["red"], g = inputs["green"], b = inputs["blue"];
  var specularity = inputs["specularity"], roughness=inputs["roughness"];

  if( Math.max(r,g,b)>1 || Math.min(r,g,b) < 0){
    return {success: false, error: "Inconsistent color values. Please use values between 0.0 and 1.0"};
  }
  if( Math.max(specularity, roughness)>1 || Math.min(specularity, roughness) < 0){
    return {success: false, error: "Inconsistent specularity or roughness values. Please use values between 0.0 and 1.0"};
  }

  inputs["alpha"]=1;
  return {success: true, object: inputs}
};

materialModule.parsePlasticAndMetal = function(material){
  var rad = material["rad"].split(" ");
  $("#red").val(rad[6]);
  $("#green").val(rad[7]);
  $("#blue").val(rad[8]);
  $("#material_specularity").val(rad[9]);
  $("#material_roughness").val(rad[10]);
}


materialModule.processPerforatedPlasticAndMetal = function(inputs){
  //Verify
  var r = inputs["red"], g = inputs["green"], b = inputs["blue"];
  var specularity = inputs["specularity"], roughness=inputs["roughness"], transparency = inputs["transparency"];

  if(Math.max(r,g,b)>1 || Math.min(r,g,b) < 0){
    return {success: false, error: "Inconsistent color values. Please use values between 0.0 and 1.0"};
  }
  if( Math.max(specularity, roughness)>1 || Math.min(specularity, roughness) < 0){
    return {success: false, error: "Inconsistent specularity or roughness values. Please use values between 0.0 and 1.0"};
  }
  if( transparency >= 1 || transparency <= 0){
    return {success: false, error: "Impossible transparency. Please use values between 0.0 and 1.0"};
  }

  inputs["alpha"]=Math.sqrt(1-transparency);
  if(inputs["alpha"] > 0.95){inputs["alpha"] = 0.95};
  inputs["base_material_name"] = utilities.fixName(inputs["name"])+"_base_material"
  return {success: true, object: inputs}
};

materialModule.parsePerforatedPlasticAndMetal = function(material){
  var rad = material["rad"].split(" ");
  $("#red").val(rad[6]);
  $("#green").val(rad[7]);
  $("#blue").val(rad[8]);
  $("#material_specularity").val(rad[9]);
  $("#material_roughness").val(rad[10]);

  var support_files = material["support_files"];
  var funcfile = support_files[0]["content"].split(" = ");
  var transparency = parseFloat(funcfile[1].replaceAll(";",""));
  $("#material_transparency").val(transparency);
};


materialModule.classes= {
  "glass" : {
    "name" : "Glass",
    "rad" : "void glass %MAT_NAME% 0 0 3 %redT% %greenT% %blueT%",
    "color_property" : "Transmittance",
    "process" : materialModule.processGlass,
    "parse" : materialModule.parseGlass
  },
  "plastic" : {
    "name" : "Plastic",
    "inputs" : {"Specularity" : 0, "Roughness" : 0},
    "rad" : "void plastic %MAT_NAME% 0 0 5 %red% %green% %blue% %specularity% %roughness%",
    "color_property" : "Reflectance",
    "process" : materialModule.processPlasticAndMetal,
    "parse" : materialModule.parsePlasticAndMetal
  },
  "metal" : {
    "name" : "Metal",
    "inputs" : {"Specularity" : 0.95, "Roughness" : 0.05},
    "rad" : "void plastic %MAT_NAME% 0 0 5 %red% %green% %blue% %specularity% %roughness%",
    "color_property" : "Reflectance",
    "process" : materialModule.processPlasticAndMetal,
    "parse" : materialModule.parsePlasticAndMetal
  },
  "perforated_plastic" : {
    "name" : "Perforated plastic",
    "inputs" : {"Specularity" : 0, "Roughness" : 0, "Transparency" : 0.25},
    "rad" : "void plastic %base_material_name% 0 0 5 %red% %green% %blue% %specularity% %roughness% void mixfunc %MAT_NAME% 4 void %base_material_name% transparency %funcfile% 0 0",
    "support_files" : [{"name" : "funcfile", "content" : "transparency = %transparency%;"}],
    "color_property" : "Base material reflectance",
    "process" : materialModule.processPerforatedPlasticAndMetal,
    "parse" : materialModule.parsePerforatedPlasticAndMetal
  },
  "perforated_metal" : {
    "name" : "Perforated metal",
    "inputs" : {"Specularity" : 0.95, "Roughness" : 0.05, "Transparency" : 0.25},
    "rad" : "void metal %base_material_name% 0 0 5 %red% %green% %blue% %specularity% %roughness% void mixfunc %MAT_NAME% 4 void %base_material_name% transparency %funcfile% 0 0",
    "support_files" : [{"name" : "funcfile", "content" : "transparency = %transparency%;"}],
    "color_property" : "Base material reflectance",
    "process" : materialModule.processPerforatedPlasticAndMetal,
    "parse" : materialModule.parsePerforatedPlasticAndMetal
  },
};





materialModule.get_material_json = function(){
    var cl = materialModule.classes[$("#material_class").val()];

    //initialize
    var object = {};

    // add the class
    object["class"] = $("#material_class").val();

    //add the inputed colors
    var r = parseFloat($("#red").val().replace(",",".")); var g = parseFloat($("#green").val().replace(",",".")); var b = parseFloat($("#blue").val().replace(",","."));
    object["red"] = r; object["green"]=g; object["blue"]=b;

    // add the sketchup color
    var su_color = $("#color_pick").spectrum("get").toRgb();
    object["color"]=[su_color.r, su_color.g, su_color.b];

    //add the name
    object["name"] = $.trim($("#material_name").val());

    //get other inputs
    if(cl.hasOwnProperty("inputs") && Object.keys(cl["inputs"]).length > 0){
      for (var input in cl["inputs"]) {
          if (cl["inputs"].hasOwnProperty(input)) {
            object[utilities.fixName(input)] = parseFloat($("#material_"+utilities.fixName(input)).val().replace(",","."));
          }
        }
    }

    //extend and validate data
    extension = cl["process"](object);
    if(!extension.success){
      return {success: false, error: extension.error}
    }
    object = extension.object;

    //create the return object
    var ret = {};
    ret["name"] = object["name"];
    ret["color"] = object["color"];
    ret["alpha"] = object["alpha"];
    ret["class"] = object["class"];
    ret["rad"] = cl["rad"];
    ret["support_files"] = [];
    //replace RAD and Support Files with the correct values.
    //Javascript was generating a pointer??... the actual materialModule.classes was
    // modified when saying ret["support_files"] = cl["support_files"];
    if(cl.hasOwnProperty("support_files") && cl["support_files"].length > 0){
        for(var i=0; i<cl["support_files"].length; i++){
          ret["support_files"].push({"name" : cl["support_files"][i]["name"], "content": cl["support_files"][i]["content"]});
        }
    }
    for (var input in object) {
        if (object.hasOwnProperty(input)) {
          ret["rad"] = ret["rad"].replaceAll("%"+input+"%",object[input])
          if(cl.hasOwnProperty("support_files") && cl["support_files"].length > 0){
              for(var i=0; i<cl["support_files"].length; i++){
                ret["support_files"][i]["content"] = ret["support_files"][i]["content"].replaceAll("%"+input+"%",object[input]);
              }
          }
        }
    }
    return {success: true, object: ret}
}


materialModule.update_list = function (filter) {
    filter = filter.toLowerCase();
    var list = $("#material_list");
    list.html("");
    if(Object.keys(materials).length == 0){
        $("<div class='center'><h4>There are no materials in your model...</h4></div>").appendTo(list);
        return;
    }
    var html = "<tr><td>Name</td><td>Class</td><td>Color</td><td></td></tr>"
    for (var material in materials) {
        if (materials.hasOwnProperty(material)) {
            var data = materials[material];
            var cl = data["class"];
            if (material.toLowerCase().indexOf(filter) >= 0 || cl.toLowerCase().indexOf(filter) >= 0) {
                var r = data["color"][0];
                var g = data["color"][1];
                var b = data["color"][2];
                var color = "rgb(" + Math.round(r) + "," + Math.round(g) + "," + Math.round(b) + ")";
                html = html + "<tr><td class='mat-name' name='" + material + "'>" + material + "</td><td class='mat-name' name='" + material + "'>" + materialModule.classes[cl]["name"] + "</td><td name='" + material + "' class='color mat-name' style='background: " + color + "'></td><td class='icons'><span name=\"" + material + "\" class='ui-icon ui-icon-trash del-material'></span><span name=\"" + material + "\" class='ui-icon ui-icon-pencil edit-material'></span></td></tr>"
            }
        }
    }
    list.html(html);

    $("td.mat-name").on("click", function () {
        var name = $(this).attr("name");
        materialModule.useMaterial(name);
    });


    $("span.del-material").on("click", function () {
        var name = $(this).attr("name");
        materialModule.deleteMaterial(name);
    });

    $("span.edit-material").on("click", function () {
        var name = $(this).attr("name");
        materialModule.editMaterial(name);
    });
}


materialModule.adaptDialog = function (cl) {
  var cl = materialModule.classes[cl]
  //$("#add_material_dialog *").show();
  //$("#color_pick").hide();
  $("#color_legend").text(cl["color_property"]);
  $("#other_material_properties").hide();
  if(cl.hasOwnProperty("inputs") && Object.keys(cl["inputs"]).length > 0){
    $("#other_material_properties").show();
    var table = $("#other_material_properties_table");
    table.empty();
    for (var input in cl["inputs"]) {
      if (cl["inputs"].hasOwnProperty(input)) {
        table.append("<tr><td>"+input+"</td><td><input type='number' step=0.01 id='material_"+utilities.fixName(input)+"' value="+cl["inputs"][input]+"></td></tr>");
      }
    }
  }
};

materialModule.deleteMaterial = function (material) {
    delete materials[material];
    materialModule.update_list("");
     window.location.href = 'skp:remove_material@'+material;
}

materialModule.editMaterial = function (material) {
  if(materials.hasOwnProperty(material)){
    var material = materials[material];
    var cl = material["class"];
    materialModule.adaptDialog(cl);
    $("#material_name").prop("disabled",true);
    var rad = material["rad"].split(" ");
    $("#material_name").val(material["name"]);
    $("#material_class").val(cl);
    $("#color_pick").spectrum("set", "rgb(" + material["color"] [0]+ "," + material["color"] [1] + "," +material["color"] [2] + ")");
    materialModule.classes[cl]["parse"](material);
  }else{
      alert("There is an error with the material you are trying to edit!");
      return false;
  }

  materialModule.add_material_dialog.dialog("open");
  return {success: true};
}


materialModule.useMaterial = function (material) {
    var msg = materials[material];
    msg["name"] = material;
     window.location.href = 'skp:use_material@'+JSON.stringify(msg);
}


materialModule.addMaterial = function () {
    var name = $.trim($("#material_name").val());
    if(materials.hasOwnProperty(name)){
        var r = confirm("This material already exists. Do you want to replace it?");
        if(!r){
          return false;
        }
    }else if(name == ""){
        alert("Please insert a valid name for the material");
        return false;
    }
    var mat = materialModule.get_material_json();


    if(!mat.success){alert(mat.error);return false}
    mat = mat.object;
    materials[name] = mat;
    materialModule.update_list("");
    materialModule.add_material_dialog.dialog("close");
     window.location.href = 'skp:add_material@'+JSON.stringify(mat);
}


materialModule.add_material_dialog = $("#add_material_dialog").dialog({
    autoOpen: false,
    modal: true,
    buttons: {
        "Add material": materialModule.addMaterial,
        Cancel: function () {
            materialModule.add_material_dialog.dialog("close");
        }
    },
    height: 0.9 * $(window).height(),
    width: 0.6 * $(window).width()
});


$("#add_material_button").button().on("click", function () {
    $("#material_name").removeAttr("disabled");
    materialModule.add_material_dialog.dialog("open");
});



$("#color_pick").spectrum({
    preferredFormat: "hex3", showInput: true
});


$("#filter_materials").keyup(function () {
    materialModule.update_list(this.value);
});


$("#material_class").on("change", function () {
    materialModule.adaptDialog(this.value);
});



$("input.color").on("change", function () {
    var r = parseFloat($("#red").val().replace(",","."));
    var g = parseFloat($("#green").val().replace(",","."));
    var b = parseFloat($("#blue").val().replace(",","."));
    if($("#monochromatic").prop("checked")){
        g=r; b=r;
    }
    $("#color_pick").spectrum("set", "rgb(" + Math.round(r*255) + "," + Math.round(g*255) + "," + Math.round(b*255) + ")");

});

$("#monochromatic").on("change",function(){
    if($(this).prop("checked")){
        $("#green").prop("disabled",true);
        $("#blue").prop("disabled",true);
        var red = $("#red").val();
        $("#green").val(red);
        $("#blue").val(red);
    }else{
        $("#green").removeAttr("disabled");
        $("#blue").removeAttr("disabled");
    }
});

$("#red").on("change",function(){
    if($("#monochromatic").prop("checked")){
        var red = $(this).val();
        $("#green").val(red);
        $("#blue").val(red);
    }
});




//Load materials in select
for (var cl in materialModule.classes) {
  if (materialModule.classes.hasOwnProperty(cl)) {

    $('#material_class').append($('<option>', {
      value: cl,
      text : materialModule.classes[cl]["name"]
    }));
  }
}
var first = "";
for (item in materialModule.classes){
  first = item;
  break;
}
materialModule.adaptDialog(first);
