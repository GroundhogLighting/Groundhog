
//Materials.js
var materialModule = {};


materialModule.transmittance2transmisivity = function(tau){    
    if(tau == 0){return 0}    
   return (Math.sqrt(0.8402528435+0.0072522239*tau*tau)-0.9166530661)/(0.0036261119*tau);            
};

materialModule.get_material_json = function(){

    var cl = $("#material_class").val();
    var r = $("#red").val(); var g = $("#green").val(); var b = $("#blue").val();    
    var su_color = $("#color_pick").spectrum("get").toRgb();
    ret = {};
    ret["color"]=[su_color.r, su_color.g, su_color.b];        
    ret["class"]=cl;    
    if(!r || !g || !b || Math.max(r,g,b) > 1 || Math.min(r,g,b) < 0){return false;}    
    switch (cl) {
        case "plastic":
            ret["alpha"]=1;
            var spec = $("#specularity").val();
            var roughness = $("#roughness").val();
            if(!spec || !roughness || Math.max(spec,roughness) > 1 || Math.min(spec,roughness) < 0){return false}
            ret["rad"] = "void plastic %MAT_NAME% 0 0 5 "+r+" "+g+" "+b+" "+spec+" "+roughness; 
            break;
        case "metal":
            ret["alpha"]=1;
            var spec = $("#specularity").val();
            var roughness = $("#roughness").val();
            if(!spec || !roughness || Math.max(spec,roughness) > 1 || Math.min(spec,roughness) < 0){return false}
            ret["rad"] = "void metal %MAT_NAME% 0 0 5 "+r+" "+g+" "+b+" "+spec+" "+roughness; 
            break;
        case "glass":             
            var r = materialModule.transmittance2transmisivity(r);
            var g = materialModule.transmittance2transmisivity(g);
            var b = materialModule.transmittance2transmisivity(b);
            if(!r || !g || !b || Math.max(r,g,b)>1 || Math.min(r,g,b) < 0){return false}
            ret["alpha"]=0.265 * r + 0.67 * g + 0.065 * b;
            ret["rad"] = "void glass %MAT_NAME% 0 0 3 "+r+" "+g+" "+b;        
            break;
        default:
            alert("ERROR: get_material_json - unkown material class!")
    }    
    return ret
}


materialModule.update_list = function (filter) {
    filter = filter.toLowerCase();
    var list = $("#material_list");
    list.html("");
    var html = "<tr><td>Name</td><td>Class</td><td>Color</td><td></td></tr>"
    for (var material in materials) {
        var data = materials[material];
        var cl = data["class"];
        if (material.toLowerCase().indexOf(filter) >= 0 || cl.toLowerCase().indexOf(filter) >= 0) {
            var r = data["color"][0];
            var g = data["color"][1];
            var b = data["color"][2];
            var color = "rgb(" + r + "," + g + "," + b + ")";
            html = html + "<tr><td class='mat-name' name=\"" + material + "\">" + material + "</td><td>" + cl + "</td><td class='color' style='background: " + color + "'></td><td class='icons'><span name=\"" + material + "\" class='ui-icon ui-icon-trash del-material'></span><span class='ui-icon ui-icon-pencil'></span></td></tr>"

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
}


materialModule.adapt_dialog = function (cl) {
    $("#add_material_dialog *").show();
    $("#color_pick").hide();
    switch (cl) {
        case "plastic":           
            break;
        case "metal":           
            break;
        case "glass":            
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



materialModule.useMaterial = function (material) {
    var msg = materials[material];
    msg["name"] = material;
    window.location.href = 'skp:use_material@'+JSON.stringify(msg);
}


materialModule.addMaterial = function () {    
    var name = $("#material_name").val();
    if(materials.hasOwnProperty(name)){
        alert("Material already exists!");
        return false;
    }
    var mat = materialModule.get_material_json();
    if(!mat){alert("Inconsistent inputs!");return false}
    materials[name] = mat;
    materialModule.update_list("");
    materialModule.add_material_dialog.dialog("close");
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


materialModule.update_list("");


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
    if(!$("#monochromatic").prop("checked")){
        var r = $("#red").val(); var g = $("#green").val(); var b = $("#blue").val();
        $("#color_pick").spectrum("set", "rgb(" + Math.round(r*255) + "," + Math.round(g*255) + "," + Math.round(b*255) + ")");
    }    
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