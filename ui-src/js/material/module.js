"use strict";
var Utilities = require("../utilities");
module.exports = (function () {
    function MaterialModule() {
        var _this = this;
        this.updateList = function (filter) {
            filter = filter.toLowerCase();
            var list = $("#material_list");
            list.html("");
            if (Object.keys(_this.materials).length == 0) {
                $("<div class='center'><h4>There are no materials in your model...</h4></div>").appendTo(list);
                return;
            }
            var html = "<tr><td>Name</td><td>Class</td><td>Color</td><td></td></tr>";
            for (var material in _this.materials) {
                if (_this.materials.hasOwnProperty(material)) {
                    var data = _this.materials[material];
                    var cl = Utilities.getMaterialType(data["class"]);
                    if (material.toLowerCase().indexOf(filter) >= 0 || cl.name.toLowerCase().indexOf(filter) >= 0) {
                        var r = data["color"][0];
                        var g = data["color"][1];
                        var b = data["color"][2];
                        var color = "rgb(" + Math.round(r) + "," + Math.round(g) + "," + Math.round(b) + ")";
                        html = html + "<tr><td class='mat-name' name='" + material + "'>" + material + "</td><td class='mat-name' name='" + material + "'>" + cl.name + "</td><td name='" + material + "' class='color mat-name' style='background: " + color + "'></td><td class='icons'><span name=\"" + material + "\" class='ui-icon ui-icon-trash del-material'></span><span name=\"" + material + "\" class='ui-icon ui-icon-pencil edit-material'></span></td></tr>";
                    }
                }
            }
            list.html(html);
            var useMaterial = _this.useMaterial;
            $("td.mat-name").on("click", function () {
                var name = $(this).attr("name");
                useMaterial(name);
            });
            var deleteMaterial = _this.deleteMaterial;
            $("span.del-material").on("click", function () {
                var name = $(this).attr("name");
                deleteMaterial(name);
            });
            var editMaterial = _this.editMaterial;
            $("span.edit-material").on("click", function () {
                var name = $(this).attr("name");
                editMaterial(name);
            });
        };
        this.adaptDialog = function (c) {
            var material = Utilities.getMaterialType(c);
            $("#color_legend").text(material.color_property);
            $("#other_material_properties").hide();
            var table = $("#other_material_properties_table");
            table.empty();
            for (var _i = 0, _a = material.inputs; _i < _a.length; _i++) {
                var input = _a[_i];
                if (["Red", "Green", "Blue"].indexOf(input.name) >= 0) {
                    $("#" + Utilities.fixName(input.name)).val(input.value);
                }
                else {
                    $("#other_material_properties").show();
                    table.append("<tr><td>" + input.name + "</td><td><input type='number' min=" + input.min + " max=" + input.max + " step=0.01 id='material_" + Utilities.fixName(input.name) + "' value=" + input.value + "></td></tr>");
                }
            }
        };
        this.get_material_json = function () {
            var cl = Utilities.getMaterialType($("#material_class").val());
            var object = {};
            object["class"] = $("#material_class").val();
            var su_color = $("#color_pick").spectrum("get").toRgb();
            object["color"] = [su_color.r, su_color.g, su_color.b];
            object["name"] = $.trim($("#material_name").val());
            for (var _i = 0, _a = cl.inputs; _i < _a.length; _i++) {
                var input = _a[_i];
                var id = "#" + Utilities.fixName(input.name);
                if (["Red", "Green", "Blue"].indexOf(input.name) < 0) {
                    id = "#material_" + Utilities.fixName(input.name);
                }
                var i = parseFloat($(id).val().replace(",", "."));
                if (i < input.min || i > input.max) {
                    alert("Please insert a valid number for " + input.name + " field");
                    return { success: false };
                }
                object[input.name] = i;
            }
            object = cl.process(object);
            var ret = {
                name: object["name"],
                color: object["color"],
                alpha: object["alpha"],
                class: object["class"],
                rad: cl["rad"],
                support_files: []
            };
            if (cl.support_files && cl.support_files.length > 0) {
                for (var _b = 0, _c = cl.support_files; _b < _c.length; _b++) {
                    var file = _c[_b];
                    ret["support_files"].push({
                        "name": file.name,
                        "content": file.content
                    });
                }
            }
            for (var input in object) {
                if (object.hasOwnProperty(input)) {
                    ret["rad"] = Utilities.replaceAll(ret["rad"], "%" + Utilities.fixName(input) + "%", object[input]);
                    if (cl.support_files && cl.support_files.length > 0) {
                        for (var i = 0; i < cl.support_files.length; i++) {
                            var s = ret["support_files"][i]["content"];
                            ret["support_files"][i]["content"] = Utilities.replaceAll(s, "%" + Utilities.fixName(input) + "%", object[input]);
                        }
                    }
                }
            }
            return { success: true, object: ret };
        };
        this.deleteMaterial = function (materialName) {
            delete _this.materials[materialName];
            _this.updateList("");
            Utilities.sendAction('remove_material', materialName);
        };
        this.editMaterial = function (name) {
            if (_this.materials.hasOwnProperty(name)) {
                var material = _this.materials[name];
                var cl = material["class"];
                _this.adaptDialog(cl);
                $("#material_class").val(Utilities.capitalize(cl));
                $("#material_name").prop("disabled", true);
                var rad = material["rad"].split(" ");
                $("#material_name").val(material["name"]);
                $("#color_pick").spectrum("set", "rgb(" + material["color"][0] + "," + material["color"][1] + "," + material["color"][2] + ")");
                var type = Utilities.getMaterialType(cl);
                type.parse(material);
            }
            else {
                alert("There is an error with the material you are trying to edit!");
                return { success: false };
            }
            _this.addMaterialDialog.dialog("open");
            return { success: true };
        };
        this.useMaterial = function (name) {
            var msg = _this.materials[name];
            msg["name"] = name;
            Utilities.sendAction("use_material", JSON.stringify(msg));
        };
        this.addMaterial = function () {
            var name = $.trim($("#material_name").val());
            if (_this.materials.hasOwnProperty(name)) {
                var r = confirm("This material already exists. Do you want to replace it?");
                if (!r) {
                    return false;
                }
            }
            else if (name == "") {
                alert("Please insert a valid name for the material");
                return false;
            }
            var res = _this.get_material_json();
            if (!res.success) {
                alert("!!!! " + res.error);
                return false;
            }
            var mat = res.object;
            _this.materials[name] = mat;
            _this.updateList("");
            _this.addMaterialDialog.dialog("close");
            Utilities.sendAction("add_material", JSON.stringify(mat));
        };
        var addMaterial = this.addMaterial;
        this.addMaterialDialog = $("#add_material_dialog").dialog({
            autoOpen: false,
            modal: true,
            buttons: {
                "Add material": addMaterial,
                Cancel: function () {
                    $(this).dialog("close");
                }
            },
            height: 0.9 * $(window).height(),
            width: 0.6 * $(window).width()
        });
        var classes = ["Glass", "Plastic", "Metal", "Perforated metal", "Perforated plastic", "Diffuser", "Fabric"];
        for (var i = 0; i < classes.length; i++) {
            var cl = classes[i];
            $("#material_class").append($('<option>', {
                value: cl,
                text: cl
            }));
        }
        this.adaptDialog(classes[0]);
        var addMaterialDialog = this.addMaterialDialog;
        $("#add_material_button").button().on("click", function () {
            $("#material_name").val("");
            $("#material_name").removeAttr("disabled");
            addMaterialDialog.dialog("open");
        });
        $("#color_pick").spectrum({
            preferredFormat: "hex3", showInput: true
        });
        var updateList = this.updateList;
        $("#filter_materials").keyup(function () {
            updateList(this.value);
        });
        var adaptDialog = this.adaptDialog;
        $("#material_class").on("change", function () {
            adaptDialog(this.value);
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
        $("#preview_button").on("click", function () {
            Utilities.sendAction('preview', 'msg');
        });
        this.materials = [];
        this.updateList("");
    }
    return MaterialModule;
}());
//# sourceMappingURL=module.js.map