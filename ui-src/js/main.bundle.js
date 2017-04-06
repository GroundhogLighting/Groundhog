(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
"use strict";
var Material = require("./material/module");
var MaterialModule = new Material();

},{"./material/module":9}],2:[function(require,module,exports){
"use strict";
var definitions_1 = require("./definitions");
module.exports = definitions_1.Material;

},{"./definitions":8}],3:[function(require,module,exports){
"use strict";
var Glass = {
    name: "Glass",
    inputs: [
        { name: "red", value: 0.7, min: 0, max: 1 },
        { name: "green", value: 0.7, min: 0, max: 1 },
        { name: "blue", value: 0.7, min: 0, max: 1 }
    ],
    rad: "void glass %MAT_NAME% 0 0 3 %redT% %greenT% %blueT%",
    color_property: "Transmittance",
    calcAlpha: function (material) {
        var r = material.getInputValue("red");
        var g = material.getInputValue("green");
        var b = material.getInputValue("blue");
        var alpha = Math.sqrt(1 - (0.265 * r + 0.67 * g + 0.065 * b));
        if (alpha > 0.95) {
            alpha = 0.95;
        }
        return alpha;
    },
    parse: function (material) {
        var rad = material.rad.split(" ");
        $("#red").val(parseFloat(rad[6]) / 1.0895);
        $("#green").val(parseFloat(rad[7]) / 1.0895);
        $("#blue").val(parseFloat(rad[8]) / 1.0895);
    }
};
module.exports = Glass;

},{}],4:[function(require,module,exports){
"use strict";
var Metal = {
    name: "Metal",
    inputs: [
        { name: "specularity", value: 0, max: 1, min: 0 },
        { name: "roughness", value: 0, max: 1, min: 0 },
        { name: "red", value: 0.6, max: 1, min: 0 },
        { name: "green", value: 0.6, max: 1, min: 0 },
        { name: "blue", value: 0.6, max: 1, min: 0 },
    ],
    rad: "void plastic %MAT_NAME% 0 0 5 %red% %green% %blue% %specularity% %roughness%",
    color_property: "Reflectance",
    calcAlpha: function (mat) {
        return 1;
    },
    parse: function (material) {
        var rad = material.rad.split(" ");
        $("#material_red").val(rad[6]);
        $("#material_green").val(rad[7]);
        $("#material_blue").val(rad[8]);
        $("#material_specularity").val(rad[9]);
        $("#material_roughness").val(rad[10]);
    }
};
module.exports = Metal;

},{}],5:[function(require,module,exports){
"use strict";
var Utilities = require("../../utilities");
var PerforatedMetal = {
    name: "Perforated metal",
    inputs: [
        { name: "red", value: 0.6, min: 0, max: 1 },
        { name: "gnreen", value: 0.6, min: 0, max: 1 },
        { name: "blue", value: 0.6, min: 0, max: 1 },
        { name: "specularity", value: 0.95, min: 0, max: 1 },
        { name: "Roughness", value: 0.05, min: 0, max: 1 },
        { name: "Transparency", value: 0.25, min: 0, max: 1 }
    ],
    rad: "void metal %base_material_name% 0 0 5 %red% %green% %blue% %specularity% %roughness% void mixfunc %MAT_NAME% 4 void %base_material_name% transparency %funcfile% 0 0",
    support_files: [{ name: "funcfile", content: "transparency = %transparency%;" }],
    color_property: "Base material reflectance",
    calcAlpha: function (material) {
        var transparency = material.getInputValue("transparency");
        return Math.sqrt(1 - transparency);
    },
    parse: function (material) {
        var rad = material["rad"].split(" ");
        $("#red").val(rad[6]);
        $("#green").val(rad[7]);
        $("#blue").val(rad[8]);
        $("#material_specularity").val(rad[9]);
        $("#material_roughness").val(rad[10]);
        var support_files = material["support_files"];
        var funcfile = support_files[0]["content"].split(" = ");
        var transparency = parseFloat(Utilities.replaceAll(funcfile[1], ";", ""));
        $("#material_transparency").val(transparency);
    }
};
module.exports = PerforatedMetal;

},{"../../utilities":10}],6:[function(require,module,exports){
"use strict";
var Utilities = require("../../utilities");
var PerforatedPlastic = {
    name: "Perforated plastic",
    inputs: [
        { name: "red", value: 0.7, min: 0, max: 1 },
        { name: "green", value: 0.7, min: 0, max: 1 },
        { name: "blue", value: 0.7, min: 0, max: 1 },
        { name: "Specularity", value: 0, min: 0, max: 1 },
        { name: "Roughness", value: 0, min: 0, max: 1 },
        { name: "Transparency", value: 0.25, min: 0, max: 1 }
    ],
    rad: "void plastic %base_material_name% 0 0 5 %red% %green% %blue% %specularity% %roughness% void mixfunc %MAT_NAME% 4 void %base_material_name% transparency %funcfile% 0 0",
    support_files: [{ name: "funcfile", content: "transparency = %transparency%;" }],
    color_property: "Base material reflectance",
    calcAlpha: function (material) {
        var transparency = material.getInputValue("transparency");
        return Math.sqrt(1 - transparency);
    },
    parse: function (material) {
        var rad = material["rad"].split(" ");
        $("#red").val(rad[6]);
        $("#green").val(rad[7]);
        $("#blue").val(rad[8]);
        $("#material_specularity").val(rad[9]);
        $("#material_roughness").val(rad[10]);
        var support_files = material["support_files"];
        var funcfile = support_files[0]["content"].split(" = ");
        var transparency = parseFloat(Utilities.replaceAll(funcfile[1], ";", ""));
        $("#material_transparency").val(transparency);
    }
};
module.exports = PerforatedPlastic;

},{"../../utilities":10}],7:[function(require,module,exports){
"use strict";
var Plastic = {
    name: "Plastic",
    inputs: [
        { name: "red", value: 0.7, min: 0, max: 1 },
        { name: "green", value: 0.7, min: 0, max: 1 },
        { name: "blue", value: 0.7, min: 0, max: 1 },
        { name: "Specularity", value: 0, min: 0, max: 1 },
        { name: "Roughness", value: 0, min: 0, max: 1 }
    ],
    rad: "void plastic %MAT_NAME% 0 0 5 %red% %green% %blue% %specularity% %roughness%",
    color_property: "Reflectance",
    calcAlpha: function (material) {
        return 1;
    },
    parse: function (material) {
        var rad = material["rad"].split(" ");
        $("#red").val(rad[6]);
        $("#green").val(rad[7]);
        $("#blue").val(rad[8]);
        $("#material_specularity").val(rad[9]);
        $("#material_roughness").val(rad[10]);
    }
};
module.exports = Plastic;

},{}],8:[function(require,module,exports){
"use strict";
var Utilities = require("../utilities");
var Material = (function () {
    function Material() {
        this.getJson = function () {
            var object = {
                name: this.name,
                class: this.class,
                color: this.color,
                rad: this.rad,
                support_files: this.support_files,
                alpha: this.alpha,
            };
            return { success: true, object: object };
        };
        var su_color = $("#color_pick").spectrum("get").toRgb();
        this.color.red = su_color.r;
        this.color.green = su_color.g;
        this.color.blue = su_color.b;
        this.class = $("#material_class").val();
        this.name = $.trim($("#material_name").val());
        var type = Utilities.getMaterialType(this.class);
        this.rad = type.rad;
        this.support_files = type.support_files;
        this.color_property = type.color_property;
        this.parse = type.parse;
        var res = this.updateInputs();
        if (!res.success) {
            alert(res.error);
            return;
        }
        this.alpha = type.calcAlpha(this);
    }
    Material.prototype.updateInputs = function () {
        var type = Utilities.getMaterialType(this.class);
        var rad = type.rad;
        var support_files = type.support_files;
        for (var _i = 0, _a = this.inputs; _i < _a.length; _i++) {
            var input = _a[_i];
            var value = $("#materiial_" + input.name).val();
            if (value > input.max) {
                return { success: false, error: 'The value of ' + input.name + ' has to be smaller than ' + input.max };
            }
            if (value < input.min) {
                return { success: false, error: 'The value of ' + input.name + ' has to be larger than ' + input.min };
            }
            input.value = value;
            rad = Utilities.replaceAll(rad, '%' + input.name + '%', String(input.value));
            for (var _b = 0, support_files_1 = support_files; _b < support_files_1.length; _b++) {
                var file = support_files_1[_b];
                file.content = Utilities.replaceAll(file.content, '%' + input.name + '%', String(input.value));
            }
        }
        this.rad = rad;
        this.support_files = support_files;
        return { success: true };
    };
    Material.prototype.getInputValue = function (name) {
        for (var _i = 0, _a = this.inputs; _i < _a.length; _i++) {
            var input = _a[_i];
            if (input.name === name) {
                return input.value;
            }
        }
    };
    return Material;
}());
exports.Material = Material;

},{"../utilities":10}],9:[function(require,module,exports){
"use strict";
var Utilities = require("../utilities");
var Material = require("./class");
module.exports = (function () {
    function MaterialModule() {
        this.addMaterialDialog = $("#add_material_dialog").dialog({
            autoOpen: false,
            modal: true,
            buttons: {
                "Add material": this.addMaterial,
                Cancel: function () {
                    this.addMaterialDialog.dialog("close");
                }
            },
            height: 0.9 * $(window).height(),
            width: 0.6 * $(window).width()
        });
        var classes = ["Plastic", "Metal", "Glass", "Perforated metal", "Perforated plastic"];
        for (var i = 0; i < classes.length; i++) {
            var cl = classes[i];
            $('#material_class').append($('<option>', {
                value: cl,
                text: cl
            }));
        }
        this.adaptDialog(classes[0]);
        $("#add_material_button").button().on("click", function () {
            $("#material_name").removeAttr("disabled");
            this.addMaterialDialog.dialog("open");
        });
        $("#color_pick").spectrum({
            preferredFormat: "hex3", showInput: true
        });
        $("#filter_materials").keyup(function () {
            this.updateList(this.value);
        });
        $("#material_class").on("change", function () {
            this.adaptDialog(this.value);
        });
        $("input.color").on("change", function () {
            var r = parseFloat($("#red").val().replace(",", "."));
            var g = parseFloat($("#green").val().replace(",", "."));
            var b = parseFloat($("#blue").val().replace(",", "."));
            if ($("#monochromatic").prop("checked")) {
                g = r;
                b = r;
            }
            $("#color_pick").spectrum("set", "rgb(" + Math.round(r * 255) + "," + Math.round(g * 255) + "," + Math.round(b * 255) + ")");
        });
        $("#monochromatic").on("change", function () {
            if ($(this).prop("checked")) {
                $("#green").prop("disabled", true);
                $("#blue").prop("disabled", true);
                var red = $("#red").val();
                $("#green").val(red);
                $("#blue").val(red);
            }
            else {
                $("#green").removeAttr("disabled");
                $("#blue").removeAttr("disabled");
            }
        });
        $("#red").on("change", function () {
            if ($("#monochromatic").prop("checked")) {
                var red = $(this).val();
                $("#green").val(red);
                $("#blue").val(red);
            }
        });
        this.materials = [];
    }
    MaterialModule.prototype.updateList = function (filter) {
        filter = filter.toLowerCase();
        var list = $("#material_list");
        list.html("");
        if (this.materials.length == 0) {
            $("<div class='center'><h4>There are no this.materials in your model...</h4></div>").appendTo(list);
            return;
        }
        var html = "<tr><td>Name</td><td>Class</td><td>Color</td><td></td></tr>";
        for (var _i = 0, _a = this.materials; _i < _a.length; _i++) {
            var material = _a[_i];
            var cl = material.class;
            if (material.name.toLowerCase().indexOf(filter) >= 0 || cl.toLowerCase().indexOf(filter) >= 0) {
                var r = material.color.red;
                var g = material.color.green;
                var b = material.color.blue;
                var color = "rgb(" + Math.round(r) + "," + Math.round(g) + "," + Math.round(b) + ")";
                html = html + "<tr><td class='mat-name' name='" + material.name + "'>" + material.name + "</td><td class='mat-name' name='" + material.name + "'>" + material.class + "</td><td name='" + material.name + "' class='color mat-name' style='background: " + color + "'></td><td class='icons'><span name=\"" + material.name + "\" class='ui-icon ui-icon-trash del-material'></span><span name=\"" + material.name + "\" class='ui-icon ui-icon-pencil edit-material'></span></td></tr>";
            }
        }
        list.html(html);
        $("td.mat-name").on("click", function () {
            var name = $(this).attr("name");
            this.useMaterial(name);
        });
        $("span.del-material").on("click", function () {
            var name = $(this).attr("name");
            this.deleteMaterial(name);
        });
        $("span.edit-material").on("click", function () {
            var name = $(this).attr("name");
            this.editMaterial(name);
        });
    };
    MaterialModule.prototype.adaptDialog = function (c) {
        var material = Utilities.getMaterialType(c);
        $("#color_legend").text(material.color_property);
        $("#other_material_properties").hide();
        var table = $("#other_material_properties_table");
        table.empty();
        for (var _i = 0, _a = material.inputs; _i < _a.length; _i++) {
            var input = _a[_i];
            if (["red", "green", "blue"].indexOf(input.name) >= 0) {
                continue;
            }
            else {
                $("#other_material_properties").show();
                table.append("<tr><td>" + input.name + "</td><td><input type='number' step=0.01 id='material_" + Utilities.fixName(input.name) + "' value=" + input.value + "></td></tr>");
            }
        }
    };
    MaterialModule.prototype.deleteMaterial = function (material) {
        this.materials = this.materials.filter(function (el) {
            return el.name !== name;
        });
        this.updateList("");
        Utilities.sendAction('remove_material', material);
    };
    MaterialModule.prototype.getMaterial = function (name) {
        for (var _i = 0, _a = this.materials; _i < _a.length; _i++) {
            var material = _a[_i];
            if (material.name === name) {
                return { success: true, object: material };
            }
        }
        return { success: false };
    };
    MaterialModule.prototype.editMaterial = function (name) {
        var res = this.getMaterial(name);
        if (res.success) {
            var material = res.object;
            this.adaptDialog(material.class);
            $("#material_name").prop("disabled", true);
            material.parse(material);
            $("#material_name").val(material.name);
            $("#material_class").val(material.class);
            $("#color_pick").spectrum("set", "rgb(" + material.color.red + "," + material.color.green + "," + material.color.blue + ")");
            material.type.parse();
            this.addMaterialDialog.dialog("open");
            return { success: true };
        }
        else {
            alert("There is an error with the material you are trying to edit!");
            return { success: false };
        }
    };
    MaterialModule.prototype.useMaterial = function (name) {
        var res = this.getMaterial(name);
        if (res.success) {
            Utilities.sendAction('use_material', res.object.name);
        }
        else {
            alert("There is an error with the material you are trying to use!");
        }
    };
    MaterialModule.prototype.addMaterial = function () {
        var name = $.trim($("#material_name").val());
        var res = this.getMaterial(name);
        var mat;
        if (res.success) {
            var r = confirm("This material already exists. Do you want to replace it?");
            if (!r) {
                return false;
            }
            mat = res.object;
        }
        else {
            if (name == "") {
                alert("Please insert a valid name for the material");
                return false;
            }
            else {
                mat = new Material();
            }
        }
        if (!mat) {
            alert("mat.error");
            return false;
        }
        this.materials.push(mat);
        this.updateList("");
        this.addMaterialDialog.dialog("close");
        Utilities.sendAction('add_material', JSON.stringify(mat.getJson()));
    };
    return MaterialModule;
}());

},{"../utilities":10,"./class":2}],10:[function(require,module,exports){
"use strict";
var Glass = require("./material/classes/glass");
var Metal = require("./material/classes/metal");
var PerforatedMetal = require("./material/classes/perforated-metal");
var Plastic = require("./material/classes/plastic");
var PerforatedPlastic = require("./material/classes/perforated-plastic");
module.exports = {
    fixName: function (name) {
        return name.toLowerCase().replace(/\s/g, "_");
    },
    sendAction: function (action, msg) {
        alert('skp:' + action + '@' + msg);
        return;
        window.location.href = 'skp:' + action + '@' + msg;
    },
    replaceAll: function (string, search, replacement) {
        return string.replace(new RegExp(search, 'g'), replacement);
    },
    getMaterialType: function (cl) {
        cl = cl.toLowerCase();
        if (cl === "plastic") {
            return Plastic;
        }
        if (cl === "metal") {
            return Metal;
        }
        if (cl === "perforated metal") {
            return PerforatedMetal;
        }
        if (cl === "perforated plastic") {
            return PerforatedPlastic;
        }
        if (cl === "glass") {
            return Glass;
        }
        new RangeError("String expected for getMaterialType() in MaterialModule");
    }
};

},{"./material/classes/glass":3,"./material/classes/metal":4,"./material/classes/perforated-metal":5,"./material/classes/perforated-plastic":6,"./material/classes/plastic":7}]},{},[1]);
