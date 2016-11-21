
//Materials.js
var materialModule = {};


materialModule.transmittance2transmisivity = function(tau){
    if(tau == 0){return 0}
    return tau*1.0895 //(Math.sqrt(0.8402528435+0.0072522239*tau*tau)-0.9166530661)/(0.0036261119*tau);
};

materialModule.transmisivity2transmittance = function(tau){
    if(tau == 0){return 0}
    return tau/1.0895
};

materialModule.get_material_json = function(){
    var cl = $("#material_class").val();
    var r = $("#red").val(); var g = $("#green").val(); var b = $("#blue").val();
    var su_color = $("#color_pick").spectrum("get").toRgb();
    ret = {};
    ret["color"]=[su_color.r, su_color.g, su_color.b];
    ret["class"]=cl;
    if(!r || !g || !b || Math.max(r,g,b) > 1 || Math.min(r,g,b) < 0){return {success: false, error: "Inconsistent color values. Please use values between 0.0 and 1.0"};}
    switch (cl) {
        case "plastic":
            ret["alpha"]=1;
            var spec = $("#specularity").val();
            var roughness = $("#roughness").val();
            if(!spec || !roughness || Math.max(spec,roughness) > 1 || Math.min(spec,roughness) < 0){return {success: false, error: "Inconsistent Roughness or Specularity values. Please use values between 0.0 and 1.0"};}
            ret["rad"] = "void plastic %MAT_NAME% 0 0 5 "+r+" "+g+" "+b+" "+spec+" "+roughness;
            break;
        case "metal":
            ret["alpha"]=1;
            var spec = $("#specularity").val();
            var roughness = $("#roughness").val();
            if(!spec || !roughness || Math.max(spec,roughness) > 1 || Math.min(spec,roughness) < 0){return {success: false, error: "Inconsistent Roughness or Specularity values. Please use values between 0.0 and 1.0"};}
            ret["rad"] = "void metal %MAT_NAME% 0 0 5 "+r+" "+g+" "+b+" "+spec+" "+roughness;
            break;
        case "glass":
            ret["alpha"]= Math.sqrt(1-(0.265 * r + 0.67 * g + 0.065 * b));
            if(!r || !g || !b || Math.max(r,g,b)>1 || Math.min(r,g,b) < 0){return {success: false, error: "Inconsistent color values. Please use values between 0.0 and 1.0"};}
            var r = materialModule.transmittance2transmisivity(r);
            var g = materialModule.transmittance2transmisivity(g);
            var b = materialModule.transmittance2transmisivity(b);
            ret["rad"] = "void glass %MAT_NAME% 0 0 3 "+r+" "+g+" "+b;
            break;
        default:
            return {success: false, error: "ERROR: get_material_json - unkown material class!"}
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
                html = html + "<tr><td class='mat-name' name=\"" + material + "\">" + material + "</td><td>" + cl + "</td><td class='color' style='background: " + color + "'></td><td class='icons'><span name=\"" + material + "\" class='ui-icon ui-icon-trash del-material'></span><span name=\"" + material + "\" class='ui-icon ui-icon-pencil edit-material'></span></td></tr>"
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


materialModule.adapt_dialog = function (cl) {
    $("#add_material_dialog *").show();
    $("#color_pick").hide();
    switch (cl) {
        case "plastic":
            $("#color_legend").text("Reflectance");
            break;
        case "metal":
            $("#color_legend").text("Reflectance");
            break;
        case "glass":
            $("#color_legend").text("Transmittance");
            $("label[for='specularity']").hide();
            $("#specularity").hide();
            $("label[for='roughness']").hide();
            $("#roughness").hide();
            break;
        default:
            alert("Unkown material selected!")
    }
};

materialModule.deleteMaterial = function (material) {
    delete materials[material];
    materialModule.update_list("");
    window.location.href = 'skp:remove_material@'+material;
}

materialModule.editMaterial = function (material) {
  if(materials.hasOwnProperty(material)){
      material = materials[material];
      rad = material["rad"].split(" ");
      cl = material["class"];
      $("#material_name").val(material["name"]);
      $("#material_class").val(cl);
      $("#color_pick").spectrum("set", "rgb(" + material["color"] [0]+ "," + material["color"] [1] + "," +material["color"] [2] + ")");
      switch (cl) {
          case "plastic":
              $("#red").val(rad[6]);
              $("#green").val(rad[7]);
              $("#blue").val(rad[8]);
              $("#specularity").val(rad[9]);
              $("#roughness").val(rad[10]);
              break;
          case "metal":
              $("#red").val(rad[6]);
              $("#green").val(rad[7]);
              $("#blue").val(rad[8]);
              $("#specularity").val(rad[9]);
              $("#roughness").val(rad[10]);
              break;
          case "glass":
              $("#red").val(materialModule.transmisivity2transmittance(rad[6]));
              $("#green").val(materialModule.transmisivity2transmittance(rad[7]));
              $("#blue").val(materialModule.transmisivity2transmittance(rad[8]));
              break;
          default:
              return {success: false, error: "ERROR: edit material - unkown material class!"}
      }
      materialModule.adapt_dialog(cl);
      materialModule.add_material_dialog.dialog("open");
      return {success: true};
  }else{
      alert("There is an error with the material you are trying to edit!");
      return false;
  }
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
    mat["name"]=name;
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
    materialModule.add_material_dialog.dialog("open");
});



$("#color_pick").spectrum({
    preferredFormat: "hex3", showInput: true
});


$("#filter_materials").keyup(function () {
    materialModule.update_list(this.value);
});


$("#material_class").on("change", function () {
    materialModule.adapt_dialog(this.value);
});



materialModule.adapt_dialog("metal");
$("#monochromatic").prop("checked",true);
$("#green").prop("disabled",true);
$("#blue").prop("disabled",true);
var red = $("#red").val();
$("#green").val(red);
$("#blue").val(red);

$("input.color").on("change", function () {

    var r = $("#red").val(); var g = $("#green").val(); var b = $("#blue").val();
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
