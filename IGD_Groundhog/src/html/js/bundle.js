(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.DesignAssistant = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
"use strict";
var Glass = require("./material/classes/glass");
var Metal = require("./material/classes/metal");
var PerforatedMetal = require("./material/classes/perforated-metal");
var Plastic = require("./material/classes/plastic");
var PerforatedPlastic = require("./material/classes/perforated-plastic");
var Diffuser = require("./material/classes/diffuser");
var Fabric = require("./material/classes/fabric");
var Lux = require("./objectives/objectives/lux");
var DF = require("./objectives/objectives/df");
var UDI = require("./objectives/objectives/udi");
var DA = require("./objectives/objectives/da");
var SkyVisibility = require("./objectives/objectives/sky_visibility");
module.exports = {
    fixName: function (name) {
        return name.toLowerCase().replace(/\s/g, "_");
    },
    sendAction: function (action, msg) {
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
        if (cl === "diffuser") {
            return Diffuser;
        }
        if (cl === "fabric") {
            return Fabric;
        }
        alert("Material Class not found at getMaterialType() in Utilities");
        return;
    },
    getObjectiveType: function (metric) {
        metric = metric.toLowerCase();
        if (metric === "lux") {
            return Lux;
        }
        if (metric === "da") {
            return DA;
        }
        if (metric === "df") {
            return DF;
        }
        if (metric === "udi") {
            return UDI;
        }
        if (metric === "sky_visibility") {
            return SkyVisibility;
        }
        new RangeError("Objective class not fund at getObjectiveType() in Utilities");
    },
    findOne: function (array, cb) {
        for (var i = 0; i < array.length; i++) {
            if (cb(array[i])) {
                return array[i];
            }
        }
    },
    capitalize: function (s) {
        return s.charAt(0).toUpperCase() + s.slice(1);
    }
};

},{"./material/classes/diffuser":6,"./material/classes/fabric":7,"./material/classes/glass":8,"./material/classes/metal":9,"./material/classes/perforated-metal":10,"./material/classes/perforated-plastic":11,"./material/classes/plastic":12,"./objectives/objectives/da":15,"./objectives/objectives/df":16,"./objectives/objectives/lux":17,"./objectives/objectives/sky_visibility":18,"./objectives/objectives/udi":19}],2:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function CalculateModule() {
        $("#set_low_parameters").on("click", function () {
            $("#ray_tracing_parameters").val("-ab 4 -ad 1000 -lw 1e-3");
            $("#elux_ray_tracing_parameters").val("-ab 4 -ad 1000 -lw 1e-3");
            $("#dc_parameters").val("-ab 4 -ad 1000 -lw 1e-3");
        });
        $("#set_med_parameters").on("click", function () {
            $("#ray_tracing_parameters").val("-ab 7 -ad 3000 -lw 1e-4");
            $("#elux_ray_tracing_parameters").val("-ab 7 -ad 3000 -lw 1e-4");
            $("#dc_parameters").val("-ab 7 -ad 3000 -lw 1e-4");
        });
        $("#set_high_parameters").on("click", function () {
            $("#ray_tracing_parameters").val("-ab 9 -ad 9999 -lw 1e-5");
            $("#elux_ray_tracing_parameters").val("-ab 9 -ad 9999 -lw 1e-5");
            $("#dc_parameters").val("-ab 9 -ad 9999 -lw 1e-5");
        });
        $("#set_low_tdd").on("click", function () {
            $("#tdd_daylight_parameters").val("-ab 3 -ad 512 -lw 1e-3");
            $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
            $("#tdd_view_parameters").val("-ab 3 -ad 512 -lw 1e-3");
        });
        $("#set_med_tdd").on("click", function () {
            $("#tdd_daylight_parameters").val("-ab 3 -ad 512 -lw 1e-3");
            $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
            $("#tdd_view_parameters").val("-ab 3 -ad 512 -lw 1e-3");
        });
        $("#set_high_tdd").on("click", function () {
            $("#tdd_daylight_parameters").val("-ab 3 -ad 1000 -lw 1e-3");
            $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
            $("#tdd_view_parameters").val("-ab 6 -ad 5512 -lw 1e-5");
        });
        $("#simulate_button").on("click", function () {
            var options = {};
            $("#calculate *").each(function () {
                var title = $(this).attr("title");
                if (title && title === "option") {
                    console.log(title);
                    if ($(this).is("input[type=checkbox]")) {
                        var id = $(this).attr("id");
                        var state = $('#' + id).is(":checked");
                        options[id] = state;
                    }
                    else {
                        options[$(this).attr("id")] = $(this).val();
                    }
                }
            });
            Utilities.sendAction("calculate", JSON.stringify(options));
        });
    }
    return CalculateModule;
}());

},{"../Utilities":1}],3:[function(require,module,exports){
"use strict";
var Utilities = require("../utilities");
module.exports = (function () {
    function LocationModule() {
        this.setWeatherData = function (weather) {
            $("#weather_city").html(weather["city"]);
            $("#weather_state").html(weather["state"]);
            $("#weather_country").html(weather["country"]);
            $("#weather_latitude").html(weather["latitude"]);
            $("#weather_longitude").html(weather["longitude"]);
            $("#weather_timezone").html("GMT " + weather["timezone"]);
        };
        $("#change_weather_button").on("click", function () {
            Utilities.sendAction("set_weather_path", "msg");
        });
        $("#get_epw_weather").on("click", function () {
            Utilities.sendAction("follow_link", "http://www.energyplus.net/weather");
        });
    }
    return LocationModule;
}());

},{"../utilities":21}],4:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function LuminairesModule() {
        var _this = this;
        this.useLuminaire = function (name) {
            var msg = _this.luminaires[name];
            msg["name"] = name;
            Utilities.sendAction("use_luminaire", JSON.stringify(msg));
        };
        this.deleteLuminaire = function (name) {
            alert("Deleting " + name);
        };
        this.updateList = function (filter) {
            var list = $("#luminaire_list");
            list.html("");
            if (Object.keys(_this.luminaires).length == 0) {
                $("<div class='center'><h4>There are no luminaires in your model...</h4></div>").appendTo(list);
                return;
            }
            filter = filter.toLowerCase();
            var html = "<tr><td>Luminaire</td><td>Manufacturer</td><td>Lamp</td></tr>";
            for (var luminaire in _this.luminaires) {
                if (_this.luminaires.hasOwnProperty(luminaire)) {
                    var data = _this.luminaires[luminaire];
                    var desc = data["luminaire"];
                    var manufacturer = data["manufacturer"];
                    var lamp = data["lamp"];
                    if (luminaire.toLowerCase().indexOf(filter) >= 0 ||
                        manufacturer.toLowerCase().indexOf(filter) >= 0 ||
                        lamp.toLowerCase().indexOf(filter) >= 0) {
                        html = html + "<tr><td class='luminaire-name' name=\"" + luminaire + "\">" + luminaire + "</td><td>" + manufacturer + "</td><td>" + lamp + "</td></tr>";
                    }
                }
            }
            list.html(html);
            $("td.luminaire-name").on("click", function () {
                var name = $(this).attr("name");
                this.useLuminaire(name);
            });
            $("span.del-luminaire").on("click", function () {
                var name = $(this).attr("name");
                this.deleteLuminaire(name);
            });
        };
        this.luminaires = {};
        var updateList = this.updateList;
        $("#filter_luminaires").keyup(function () {
            updateList(this.value);
        });
        $("#elux_preview").on("click", function () {
            Utilities.sendAction("preview", "msg");
        });
        $("#elux_night_preview").on("click", function () {
            Utilities.sendAction("night_preview", "msg");
        });
        this.updateList("");
    }
    return LuminairesModule;
}());

},{"../Utilities":1}],5:[function(require,module,exports){
"use strict";
var Utilities = require("./utilities");
var Material = require("./material/module");
var Location = require("./location/module");
var Objectives = require("./objectives/module");
var Luminaires = require("./luminaires/module");
var Calculate = require("./calculate/module");
var Report = require("./report/module");
module.exports = (function () {
    function DesignAssistant() {
        this.update = function () {
            Utilities.sendAction("on_load", "msg");
        };
        var MaterialsModule = new Material();
        this.materials = MaterialsModule;
        var LocationModule = new Location();
        this.location = LocationModule;
        var ObjectivesModule = new Objectives();
        this.objectives = ObjectivesModule;
        var CalculateModule = new Calculate();
        this.calculate = CalculateModule;
        var ReportModule = new Report();
        this.report = ReportModule;
        var LuminairesModule = new Luminaires();
        this.luminaires = LuminairesModule;
    }
    return DesignAssistant;
}());

},{"./calculate/module":2,"./location/module":3,"./luminaires/module":4,"./material/module":13,"./objectives/module":14,"./report/module":20,"./utilities":21}],6:[function(require,module,exports){
"use strict";
var Diffuser = {
    name: "Diffuser",
    inputs: [
        { name: "Red", value: 0.7, min: 0, max: 1 },
        { name: "Green", value: 0.7, min: 0, max: 1 },
        { name: "Blue", value: 0.7, min: 0, max: 1 },
        { name: "Diffuse Reflectance", value: 0.2, min: 0.01, max: 1 },
    ],
    rad: "void trans %MAT_NAME% 0 0 7 %red% %green% %blue% 0 0 %total_transmittance% 0",
    color_property: "Diffuse Transmittance",
    process: function (inputs) {
        var rd = inputs["Diffuse Reflectance"];
        var td = 0.265 * inputs["Red"] + 0.67 * inputs["Green"] + 0.065 * inputs["Blue"];
        if (td + rd > 1) {
            alert("Reflectance and Transmittance are too high. Please lower at least one of them.");
            return;
        }
        var a6 = td / (td + rd);
        inputs["Red"] = inputs["Red"] / a6;
        inputs["Green"] = inputs["Green"] / a6;
        inputs["Blue"] = inputs["Blue"] / a6;
        inputs["Total Transmittance"] = a6;
        inputs["alpha"] = Math.sqrt(1 - td);
        if (inputs["alpha"] > 0.95) {
            inputs["alpha"] = 0.95;
        }
        ;
        return inputs;
    },
    parse: function (material) {
        var rad = material["rad"];
        var data = rad.split(" ");
        var c_red = parseFloat(data[6]);
        var c_green = parseFloat(data[7]);
        var c_blue = parseFloat(data[8]);
        var a6 = parseFloat(data[11]);
        var red = c_red * a6;
        var green = c_green * a6;
        var blue = c_blue * a6;
        var rdx = c_red - red;
        var rdy = c_green - green;
        var rdz = c_blue - blue;
        var rd = 0.265 * rdx + 0.67 * rdy + 0.065 * rdz;
        $("#red").val(red);
        $("#green").val(green);
        $("#blue").val(blue);
        $("#material_diffuse_transmittance").val(rd);
    }
};
module.exports = Diffuser;

},{}],7:[function(require,module,exports){
"use strict";
var Diffuser = {
    name: "Fabric",
    inputs: [
        { name: "Red", value: 0.04, min: 0, max: 1 },
        { name: "Green", value: 0.04, min: 0, max: 1 },
        { name: "Blue", value: 0.04, min: 0, max: 1 },
        { name: "Direct Transmittance", value: 0.12, min: 0.01, max: 0.99 },
        { name: "Diffuse Reflectance", value: 0.05, min: 0.01, max: 1 }
    ],
    rad: "void trans %base_material_name% 0 0 7 %red% %green% %blue% 0 0 %total_transmittance% 0  void mixfunc %MAT_NAME% 4 void %base_material_name% direct_transmittance %funcfile% 0 0",
    support_files: [{ name: "funcfile", content: "direct_transmittance = %direct_transmittance%;" }],
    color_property: "Diffuse Transmittance",
    process: function (inputs) {
        var ts = inputs["Direct Transmittance"];
        var td = 0.265 * inputs["Red"] + 0.67 * inputs["Green"] + 0.065 * inputs["Blue"];
        var rd = inputs["Diffuse Reflectance"];
        if (ts + td + rd > 1) {
            alert("Reflectance and Transmittance are too high. Please lower at least one of them.");
            return;
        }
        var a6 = td / (td + rd);
        inputs["Red"] = inputs["Red"] / (a6 * (1 - ts));
        inputs["Green"] = inputs["Green"] / (a6 * (1 - ts));
        inputs["Blue"] = inputs["Blue"] / (a6 * (1 - ts));
        inputs["Total Transmittance"] = a6;
        inputs["base_material_name"] = inputs["name"].toLowerCase().replace(/\s/g, "_") + "_base_material";
        inputs["alpha"] = Math.sqrt(1 - td - ts);
        if (inputs["alpha"] > 0.95) {
            inputs["alpha"] = 0.95;
        }
        ;
        return inputs;
    },
    parse: function (material) {
        var support_files = material["support_files"];
        var funcfile = support_files[0]["content"].split(" = ");
        var transparency = parseFloat(funcfile[1].replace(new RegExp(";", 'g'), ""));
        var rad = material["rad"];
        var data = rad.split(" ");
        var c_red = parseFloat(data[6]);
        var c_green = parseFloat(data[7]);
        var c_blue = parseFloat(data[8]);
        var a6 = parseFloat(data[11]);
        var red = c_red * a6 * (1 - transparency);
        var green = c_green * a6 * (1 - transparency);
        var blue = c_blue * a6 * (1 - transparency);
        var rdx = c_red - red;
        var rdy = c_green - green;
        var rdz = c_blue - blue;
        var rd = 0.265 * rdx + 0.67 * rdy + 0.065 * rdz;
        $("#red").val(red);
        $("#green").val(green);
        $("#blue").val(blue);
        $("#material_diffuse_transmittance").val(rd);
        $("#material_direct_transmittance").val(transparency);
    }
};
module.exports = Diffuser;

},{}],8:[function(require,module,exports){
"use strict";
var Glass = {
    name: "Glass",
    inputs: [
        { name: "Red", value: 0.7, min: 0, max: 1 },
        { name: "Green", value: 0.7, min: 0, max: 1 },
        { name: "Blue", value: 0.7, min: 0, max: 1 }
    ],
    rad: "void glass %MAT_NAME% 0 0 3 %red% %green% %blue%",
    color_property: "Transmittance",
    process: function (inputs) {
        inputs["Red"] = inputs["Red"] * 1.0895;
        inputs["Green"] = inputs["Green"] * 1.0895;
        inputs["Blue"] = inputs["Blue"] * 1.0895;
        inputs["alpha"] = Math.sqrt(1 - (0.265 * inputs["Red"] + 0.67 * inputs["Green"] + 0.065 * inputs["Blue"]));
        if (inputs["alpha"] > 0.95) {
            inputs["alpha"] = 0.95;
        }
        ;
        return inputs;
    },
    parse: function (material) {
        var rad = material["rad"];
        var data = rad.split(" ");
        $("#red").val(parseFloat(data[6]) / 1.0895);
        $("#green").val(parseFloat(data[7]) / 1.0895);
        $("#blue").val(parseFloat(data[8]) / 1.0895);
    }
};
module.exports = Glass;

},{}],9:[function(require,module,exports){
"use strict";
var Metal = {
    name: "Metal",
    inputs: [
        { name: "Specularity", value: 0, max: 1, min: 0 },
        { name: "Roughness", value: 0, max: 1, min: 0 },
        { name: "Red", value: 0.6, max: 1, min: 0 },
        { name: "Green", value: 0.6, max: 1, min: 0 },
        { name: "Blue", value: 0.6, max: 1, min: 0 },
    ],
    rad: "void plastic %MAT_NAME% 0 0 5 %red% %green% %blue% %specularity% %roughness%",
    color_property: "Reflectance",
    process: function (inputs) {
        inputs["alpha"] = 1;
        return inputs;
    },
    parse: function (material) {
        var rad = material["rad"];
        var data = rad.split(" ");
        $("#red").val(data[6]);
        $("#reen").val(data[7]);
        $("#blue").val(data[8]);
        $("#material_specularity").val(data[9]);
        $("#material_roughness").val(data[10]);
    }
};
module.exports = Metal;

},{}],10:[function(require,module,exports){
"use strict";
var PerforatedMetal = {
    name: "Perforated metal",
    inputs: [
        { name: "Red", value: 0.6, min: 0, max: 1 },
        { name: "Green", value: 0.6, min: 0, max: 1 },
        { name: "Blue", value: 0.6, min: 0, max: 1 },
        { name: "Specularity", value: 0.95, min: 0, max: 1 },
        { name: "Roughness", value: 0.05, min: 0, max: 1 },
        { name: "Transparency", value: 0.25, min: 0, max: 1 }
    ],
    rad: "void metal %base_material_name% 0 0 5 %red% %green% %blue% %specularity% %roughness% void mixfunc %MAT_NAME% 4 void %base_material_name% transparency %funcfile% 0 0",
    support_files: [{ name: "funcfile", content: "transparency = %transparency%;" }],
    color_property: "Base material reflectance",
    process: function (inputs) {
        inputs["alpha"] = Math.sqrt(1 - parseFloat(inputs["Transparency"]));
        if (inputs["alpha"] > 0.95) {
            inputs["alpha"] = 0.95;
        }
        ;
        inputs["base_material_name"] = inputs["name"].toLowerCase().replace(/\s/g, "_") + "_base_material";
        return inputs;
    },
    parse: function (material) {
        var rad = material["rad"];
        var data = rad.split(" ");
        $("#red").val(data[6]);
        $("#green").val(data[7]);
        $("#blue").val(data[8]);
        $("#material_specularity").val(data[9]);
        $("#material_roughness").val(data[10]);
        var support_files = material["support_files"];
        var funcfile = support_files[0]["content"].split(" = ");
        var transparency = parseFloat(funcfile[1].replace(new RegExp(";", 'g'), ""));
        $("#material_transparency").val(transparency);
    }
};
module.exports = PerforatedMetal;

},{}],11:[function(require,module,exports){
"use strict";
var PerforatedPlastic = {
    name: "Perforated plastic",
    inputs: [
        { name: "Red", value: 0.7, min: 0, max: 1 },
        { name: "Green", value: 0.7, min: 0, max: 1 },
        { name: "Blue", value: 0.7, min: 0, max: 1 },
        { name: "Specularity", value: 0, min: 0, max: 1 },
        { name: "Roughness", value: 0, min: 0, max: 1 },
        { name: "Transparency", value: 0.25, min: 0, max: 1 }
    ],
    rad: "void plastic %base_material_name% 0 0 5 %red% %green% %blue% %specularity% %roughness% void mixfunc %MAT_NAME% 4 void %base_material_name% transparency %funcfile% 0 0",
    support_files: [{ name: "funcfile", content: "transparency = %transparency%;" }],
    color_property: "Base material reflectance",
    process: function (inputs) {
        inputs["alpha"] = Math.sqrt(1 - parseFloat(inputs["Transparency"]));
        if (inputs["alpha"] > 0.95) {
            inputs["alpha"] = 0.95;
        }
        ;
        inputs["base_material_name"] = inputs["name"].toLowerCase().replace(/\s/g, "_") + "_base_material";
        return inputs;
    },
    parse: function (material) {
        var rad = material["rad"];
        var data = rad.split(" ");
        $("#red").val(data[6]);
        $("#green").val(data[7]);
        $("#blue").val(data[8]);
        $("#material_specularity").val(data[9]);
        $("#material_roughness").val(data[10]);
        var support_files = material["support_files"];
        var funcfile = support_files[0]["content"].split(" = ");
        var transparency = parseFloat(funcfile[1].replace(new RegExp(";", 'g'), ""));
        $("#material_transparency").val(transparency);
    }
};
module.exports = PerforatedPlastic;

},{}],12:[function(require,module,exports){
"use strict";
var Plastic = {
    name: "Plastic",
    inputs: [
        { name: "Red", value: 0.7, min: 0, max: 1 },
        { name: "Green", value: 0.7, min: 0, max: 1 },
        { name: "Blue", value: 0.7, min: 0, max: 1 },
        { name: "Specularity", value: 0, min: 0, max: 1 },
        { name: "Roughness", value: 0, min: 0, max: 1 }
    ],
    rad: "void plastic %MAT_NAME% 0 0 5 %red% %green% %blue% %specularity% %roughness%",
    color_property: "Reflectance",
    process: function (inputs) {
        inputs["alpha"] = 1;
        return inputs;
    },
    parse: function (material) {
        var rad = material["rad"];
        var data = rad.split(" ");
        $("#red").val(data[6]);
        $("#green").val(data[7]);
        $("#blue").val(data[8]);
        $("#material_specularity").val(data[9]);
        $("#material_roughness").val(data[10]);
    }
};
module.exports = Plastic;

},{}],13:[function(require,module,exports){
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

},{"../utilities":21}],14:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
var Lux = require("./objectives/lux");
var DF = require("./objectives/df");
var UDI = require("./objectives/udi");
var DA = require("./objectives/da");
var SkyVisibility = require("./objectives/sky_visibility");
module.exports = (function () {
    function ObjectivesModule() {
        var _this = this;
        this.metrics = [Lux, DF, UDI, DA, SkyVisibility];
        this.add_objective = function (wp_name, obj_name) {
            var message = { "workplane": wp_name, "objective": obj_name };
            Utilities.sendAction("add_objective", JSON.stringify(message));
        };
        this.get_human_description = function (metric) {
            var description = metric.human_language;
            var requirements = metric.requirements;
            for (var _i = 0, requirements_1 = requirements; _i < requirements_1.length; _i++) {
                var item = requirements_1[_i];
                if (item.value !== null && typeof item.value === 'object') {
                    for (var sub_item_name in item.value) {
                        if (item.value.hasOwnProperty(sub_item_name)) {
                            description = Utilities.replaceAll(description, "%" + item.name + "_" + sub_item_name + "%", $("#objective_" + item.name + "_" + sub_item_name).val());
                        }
                    }
                }
                else {
                    description = Utilities.replaceAll(description, "%" + item.name + "%", $("#objective_" + item.name).val());
                }
            }
            return description;
        };
        this.update_human_description = function () {
            var metric = $("#metric").val();
            metric = Utilities.getObjectiveType(metric);
            $("#objective_human_description").text(_this.get_human_description(metric));
        };
        this.create_objective = function () {
            var failure = { success: false };
            var metric = $("#metric").val();
            var res = _this.get_objective_object(metric);
            if (!res.success) {
                alert(res.error);
                return failure;
            }
            var objective = res.object;
            var name = objective["name"];
            if (_this.objectives.hasOwnProperty(name)) {
                var r = confirm("This objective already exists. Do you want to replace it?");
                if (!r) {
                    return failure;
                }
            }
            else if (name == "") {
                alert("Please insert a valid name for the objective");
                return failure;
            }
            _this.objectives[name] = objective;
            _this.update_objectives("");
            _this.add_objective_dialog.dialog("close");
            DesignAssistant.objective.update_objective_summary();
            Utilities.sendAction("create_objective", JSON.stringify(objective));
            return { success: true };
        };
        this.remove_objective = function (workplane, objective) {
            Utilities.sendAction("remove_objective", JSON.stringify({ "workplane": workplane, "objective": objective }));
        };
        this.adapt_objective_dialog = function (metric_name) {
            var metric = Utilities.getObjectiveType(metric_name);
            $("#create_objective_dialog").children().hide();
            $("#objective_good_pixel").hide();
            $("label[for='objective_good_pixel']").hide();
            $("#objective_name_field").show();
            $("#metric_field").show();
            $("#compliance_field").show();
            $("#human_description").show();
            var _loop_1 = function (item) {
                $("#objective_" + item.name).show();
                $("label[for='objective_" + item.name + "']").show();
                if (item.value !== null && typeof item.value === 'object') {
                    for (var sub_item_name in item.value) {
                        if (item.value.hasOwnProperty(sub_item_name)) {
                            var sub_item = item.value[sub_item_name];
                            $("#objective_" + item.name + "_" + sub_item_name).val(sub_item);
                        }
                    }
                }
                else {
                    var req = Utilities.findOne(metric.requirements, function (e) {
                        return e.name === item.name;
                    });
                    $("#objective_" + item.name).val(req.name);
                }
            };
            for (var _i = 0, _a = metric.requirements; _i < _a.length; _i++) {
                var item = _a[_i];
                _loop_1(item);
            }
            $("#objective_good_light_legend").text(metric.good_light_legend);
            _this.update_human_description();
        };
        this.get_objective_object = function (metric_name) {
            var ret = {};
            ret["name"] = $.trim($("#objective_name").val());
            ret["metric"] = metric_name;
            var metric = Utilities.getObjectiveType(metric_name);
            ret["dynamic"] = metric.dynamic;
            for (var _i = 0, _a = metric.requirements; _i < _a.length; _i++) {
                var item = _a[_i];
                if (item.value !== null && typeof item.value === 'object') {
                    ret[item.name] = {};
                    for (var sub_item_name in item.value) {
                        if (item.value.hasOwnProperty(sub_item_name)) {
                            var input = $("#objective_" + item.name + "_" + sub_item_name);
                            ret[item.name][sub_item_name] = input.val();
                            if (input.attr("type") === "number") {
                                ret[item.name][sub_item_name] = parseFloat(ret[item.name][sub_item_name]);
                            }
                        }
                    }
                }
                else {
                    ret[item.name] = parseFloat($("#objective_" + item.name).val());
                }
            }
            $("#objective_good_light_legend").text(metric.good_light_legend);
            return { success: true, object: ret };
        };
        this.update_objectives = function (filter) {
            var list = $("#objectives_list");
            list.html("");
            if (Object.keys(_this.objectives).length == 0) {
                $("<div class='center'><h4>There are no objectives in your model...</h4></div>").appendTo(list);
                return;
            }
            filter = filter.toLowerCase();
            for (var objective in _this.objectives) {
                if (_this.objectives.hasOwnProperty(objective)) {
                    if (objective.toLowerCase().indexOf(filter) >= 0) {
                        var new_row = $("<tr></tr>");
                        var drag = $(("<td name='" + objective + "'>" + objective + "</td>"));
                        new_row.append(drag);
                        var action_column = $("<td></td>");
                        var delete_button = $("<span name=\"" + objective + "\" class='ui-icon ui-icon-trash del-material'></span>");
                        var edit_button = $("<span name=\"" + objective + "\" class='ui-icon ui-icon-pencil edit-material'></span>");
                        delete_button.on("click", function () {
                            var objective_name = $(this).attr("name");
                            Utilities.sendAction("delete_objective", objective_name);
                        });
                        edit_button.on("click", function () {
                            var objective_name = $(this).attr("name");
                            this.editObjective(objective_name);
                        });
                        new_row.append(action_column);
                        action_column.append(edit_button);
                        action_column.append(delete_button);
                        drag.draggable({
                            appendTo: "body",
                            helper: "clone"
                        });
                        list.append(new_row);
                    }
                }
            }
        };
        this.parseObjective = function (obj) {
            _this.adapt_objective_dialog(obj.metric);
            $("#metric").val(obj["metric"]);
            $("#objective_name").val(obj.name);
            var metric = Utilities.getObjectiveType(obj.metric);
            for (var _i = 0, _a = metric.requirements; _i < _a.length; _i++) {
                var item = _a[_i];
                if (item.value !== null && typeof item.value === 'object') {
                    for (var sub_item_name in item.value) {
                        if (item.value.hasOwnProperty(sub_item_name)) {
                            $("#objective_" + item.name + "_" + sub_item_name).val(obj[item.name][sub_item_name]);
                        }
                    }
                }
                else {
                    $("#objective_" + item.name).val(obj[item.name]);
                }
            }
        };
        this.editObjective = function (objective_name) {
            $("#objective_name").prop("disabled", true);
            var obj = _this.objectives[objective_name];
            var metric = Utilities.getObjectiveType(obj["metric"]);
            _this.parseObjective(obj);
            _this.add_objective_dialog.dialog("open");
        };
        this.get_new_row_for_workplane = function (workplane, objective) {
            var row = $("<tr></tr>");
            var name_column = $("<td>" + objective + "</td>");
            row.append(name_column);
            var actions_column = $("<td></td>");
            var delete_button = $("<span name='" + workplane + "' title='" + objective + "' class='ui-icon ui-icon-trash del-objective'></span>");
            delete_button.on("click", function () {
                var wp = $(this).attr("name");
                var obj = $(this).parent().siblings("td").text();
                this.remove_objective(wp, obj);
            });
            actions_column.append(delete_button);
            row.append(actions_column);
            return row;
        };
        this.update_workplanes = function (filter) {
            var ul = $("#workplane_objectives");
            ul.html("");
            if (Object.keys(_this.workplanes).length === 0) {
                $("<div class='center'><h4>There are no workplanes in your model...</h4></div>").appendTo(ul);
                return;
            }
            filter = filter.toLowerCase();
            for (var wp_name in _this.workplanes) {
                if (_this.workplanes.hasOwnProperty(wp_name)) {
                    if (wp_name.toLowerCase().indexOf(filter) >= 0) {
                        var li = $("<li></li>");
                        var title = $("<h1></h1>");
                        title.text(wp_name);
                        li.append(title);
                        li.droppable({
                            hoverClass: "hover",
                            accept: ":not(.ui-sortable-helper)",
                            drop: function (event, ui) {
                                if ("TD" != ui.draggable.prop("tagName")) {
                                    return;
                                }
                                ;
                                var wp_name = $(_this).find("h1").text();
                                var table_name = Utilities.fixName(wp_name) + "_objectives";
                                var objective = ui.draggable.attr("name");
                                if (_this.workplanes[wp_name].indexOf(objective) >= 0) {
                                    alert("That workplane has already been assigned that objective!");
                                    return;
                                }
                                var new_row = _this.get_new_row_for_workplane(wp_name, objective);
                                var table = $("#" + table_name);
                                if (table.length == 0) {
                                    $(_this).find("div").remove();
                                    table = $("<table id='" + table_name + "'></table>");
                                    table.appendTo($(_this));
                                }
                                new_row.appendTo(table);
                                _this.workplanes[wp_name].push(objective);
                                _this.add_objective(wp_name, objective);
                            }
                        });
                        ul.append(li);
                        var objectives = _this.workplanes[wp_name];
                        if (objectives.length == 0) {
                            li.append($("<div>Drop objectives here</div>"));
                            li.addClass("empty");
                        }
                        else {
                            var table = $("<table id='" + Utilities.fixName(wp_name) + "_objectives'>");
                            for (var i = 0; i < objectives.length; i++) {
                                var row = _this.get_new_row_for_workplane(wp_name, objectives[i]);
                                table.append(row);
                            }
                            li.append(table);
                        }
                    }
                }
            }
        };
        this.objectives = {};
        this.workplanes = {};
        var create_objective = this.create_objective;
        this.add_objective_dialog = $("#create_objective_dialog").dialog({
            autoOpen: false,
            modal: true,
            buttons: {
                "Create objective": create_objective,
                Cancel: function () {
                    $(this).dialog("close");
                }
            },
            height: 0.8 * $(window).height(),
            width: 0.6 * $(window).width()
        });
        var update_workplanes = this.update_workplanes;
        $("#workplane_objectives_filter").keyup(function () {
            update_workplanes(this.value);
        });
        var adapt_objective_dialog = this.adapt_objective_dialog;
        $("#metric").on("change", function () {
            adapt_objective_dialog(this.value);
        });
        var add_objective_dialog = this.add_objective_dialog;
        $("#create_objective_button").button().on("click", function () {
            $("#objective_name").removeAttr("disabled");
            add_objective_dialog.dialog("open");
        });
        $("#objective_date_date").datepicker();
        var update_human_description = this.update_human_description;
        $(".resizable1").resizable({
            autoHide: true,
            handles: 'e',
            resize: function (e, ui) {
                var parent = ui.element.parent();
                var remainingSpace = parent.width() - ui.element.outerWidth(), divTwo = ui.element.next(), divTwoWidth = (remainingSpace - divTwo.outerWidth() + divTwo.width()) / parent.width() * 98 + "%";
                divTwo.width(divTwoWidth);
            },
            stop: function (e, ui) {
                var parent = ui.element.parent();
                ui.element.css({
                    width: ui.element.width() / parent.width() * 100 + "%",
                });
            }
        });
        $("#create_objective_dialog input").change(function () {
            update_human_description();
        });
        for (var _i = 0, _a = this.metrics; _i < _a.length; _i++) {
            var metric = _a[_i];
            $('#metric').append($('<option>', {
                value: metric.metric,
                text: metric.name
            }));
        }
        this.adapt_objective_dialog(this.metrics[0].metric);
        var update_objectives = this.update_objectives;
        $("#objectives_filter").keyup(function () {
            update_objectives(this.value);
        });
        this.update_objectives("");
        this.update_workplanes("");
    }
    return ObjectivesModule;
}());

},{"../Utilities":1,"./objectives/da":15,"./objectives/df":16,"./objectives/lux":17,"./objectives/sky_visibility":18,"./objectives/udi":19}],15:[function(require,module,exports){
"use strict";
var Da = {
    metric: "DA",
    name: "Daylight Autonomy",
    dynamic: true,
    human_language: "Workplane is in compliance when at least %goal%% of the space achieves an illuminance of %good_light_min%lux or more for a minimum of %good_pixel%% of the occupied time by daylight only. Occupied time is between %occupied_min% and %occupied_max% hours, from months %sim_period_min% to %sim_period_max%.",
    good_light_legend: "Illuminance goal (lux)",
    requirements: [
        {
            name: "good_pixel",
            value: 50
        },
        {
            name: "good_light",
            value: { "min": 300, "has_min": true, "has_max": false, "max": false }
        },
        {
            name: "goal",
            value: 50
        },
        {
            name: "occupied",
            value: { "min": 8, "has_min": true, "has_max": true, "max": 18 }
        },
        {
            name: "sim_period",
            value: { "min": 1, "has_min": true, "has_max": true, "max": 12 }
        }
    ],
};
module.exports = Da;

},{}],16:[function(require,module,exports){
"use strict";
var Df = {
    metric: "DF",
    name: "Daylight Factor",
    dynamic: false,
    human_language: "Workplane is in compliance when at least %goal%% of the space presents a Daylight Factor between %good_light_min%% and %good_light_max%%.",
    good_light_legend: "Daylight Factor goal (%)",
    requirements: [
        {
            name: "good_light",
            value: {
                "min": 2, "has_min": true, "max": 10, "has_max": true
            }
        },
        {
            name: "goal",
            value: 50
        }
    ]
};
module.exports = Df;

},{}],17:[function(require,module,exports){
"use strict";
var Lux = {
    metric: "LUX",
    name: "Illuminance under clear sky",
    dynamic: false,
    human_language: "Workplane is in compliance when at least %goal%% of the space presents an illuminance between %good_light_min%lux and %good_light_max%lux under a clear sky at %date_hour% hours on %date_date%.",
    good_light_legend: "Illuminance goal (lux)",
    requirements: [
        {
            name: "good_light",
            value: {
                "min": 300, "has_min": true, "max": 200, "has_max": true
            }
        },
        {
            name: "goal",
            value: 50
        },
        {
            name: "date",
            value: {
                "date": "",
                "hour": 12
            }
        }
    ]
};
module.exports = Lux;

},{}],18:[function(require,module,exports){
"use strict";
var SkyVisibility = {
    metric: "SKY_VISIBILITY",
    name: "Sky Visibility",
    dynamic: false,
    human_language: "Workplane is in compliance when at least %goal%% of the space receives direct light from the sky.",
    good_light_legend: "Sky Visibility",
    requirements: [
        {
            name: "goal",
            value: 80
        }
    ]
};
module.exports = SkyVisibility;

},{}],19:[function(require,module,exports){
"use strict";
var Udi = {
    metric: "UDI",
    name: "Useful Daylight Illuminance",
    dynamic: true,
    human_language: "Workplane is in compliance when at least %goal%% of the space achieves an illuminance between %good_light_min%lux and %good_light_max%lux during for a minimum of %good_pixel%% of the occupied time by daylight only. Occupied time is between %occupied_min% and %occupied_max% hours, from months %sim_period_min% to %sim_period_max%.",
    good_light_legend: "Illuminance goal (lux)",
    requirements: [
        {
            name: "good_pixel",
            value: 50
        },
        {
            name: "good_light",
            value: { "min": 300, "has_min": true, "has_max": true, "max": 3000 }
        },
        {
            name: "goal",
            value: 50
        },
        {
            name: "occupied",
            value: { "min": 8, "has_min": true, "has_max": true, "max": 18 }
        },
        {
            name: "sim_period",
            value: { "min": 1, "has_min": true, "has_max": true, "max": 12 }
        }
    ],
};
module.exports = Udi;

},{}],20:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function Report() {
        var _this = this;
        this.update_objective_summary = function () {
            var div = $("#objective_summary");
            div.html("");
            var objs = Object.keys(DesignAssistant.objectives.objectives);
            for (var i = 0; i < objs.length; i++) {
                var newDiv = $("<div></div>");
                var name_1 = $("<h4>" + objs[i] + "</h4>");
                newDiv.append(name_1);
                var obj = DesignAssistant.objectives.objectives[objs[i]];
                DesignAssistant.objectives.parseObjective(obj);
                var metric = Utilities.getObjectiveType(obj.metric);
                var text = DesignAssistant.objectives.get_human_description(metric);
                var description = $("<p>" + text + "</p>");
                newDiv.append(description);
                div.append(newDiv);
            }
        };
        this.highlight_objective = function (objective) {
            $('#compliance_summary tr:first-child').each(function () {
                $(this).children().each(function () {
                    var o = $(this).text();
                    if (o == objective) {
                        $(this).addClass('selected');
                    }
                    else {
                        $(this).removeClass('selected');
                    }
                });
            });
        };
        this.update_elux_compliance_summary = function () {
            var table = $("#elux_compliance_summary");
            table.html("");
            var header = $("<tr><td></td><td>Average (lux)</td><td>Min/Average</td><td>Min/Max</td></tr>");
            table.append(header);
            for (var wp_name in _this.elux_results) {
                if (_this.elux_results.hasOwnProperty(wp_name)) {
                    var row = $("<tr></tr>");
                    var data = _this.elux_results[wp_name];
                    row.append($("<td>" + wp_name + "</td>"));
                    row.append($("<td>" + Math.round(data["average"]) + "</td>"));
                    row.append($("<td>" + Math.round(data["min_over_average"] * 100) / 100 + "</td>"));
                    row.append($("<td>" + Math.round(data["min_over_max"] * 100) / 100 + "</td>"));
                    table.append(row);
                }
            }
        };
        this.update_compliance_summary = function () {
            var table = $("#compliance_summary");
            table.html("");
            var objs = Object.keys(DesignAssistant.objectives.objectives);
            var header = $("<tr></tr>");
            header.append($("<td></td>"));
            for (var i = 0; i < objs.length; i++) {
                var name_2 = $("<td>" + objs[i] + "</td>");
                name_2.on("click", function () {
                    Utilities.sendAction("remark", $(this).text());
                });
                header.append(name_2);
            }
            table.append(header);
            for (var wp_name in _this.results) {
                if (_this.results.hasOwnProperty(wp_name)) {
                    var row = $("<tr></tr>");
                    row.append($("<td>" + wp_name + "</td>"));
                    for (var i = 0; i < objs.length; i++) {
                        var obj_name = objs[i];
                        var col = $("<td></td>");
                        if (_this.results[wp_name].hasOwnProperty(obj_name)) {
                            var s = _this.results[wp_name][obj_name] * 100;
                            col.text(Math.round(s) + "%");
                            if (DesignAssistant.objectives.objectives[obj_name]["goal"] <= s) {
                                col.addClass("success");
                            }
                            else {
                                col.addClass("not-success");
                            }
                        }
                        row.append(col);
                    }
                    table.append(row);
                }
            }
        };
        this.results = {};
        this.elux_results = {};
        $("#remark_elux").on("click", function () {
            Utilities.sendAction("remark", "ELUX");
        });
    }
    return Report;
}());

},{"../Utilities":1}],21:[function(require,module,exports){
arguments[4][1][0].apply(exports,arguments)
},{"./material/classes/diffuser":6,"./material/classes/fabric":7,"./material/classes/glass":8,"./material/classes/metal":9,"./material/classes/perforated-metal":10,"./material/classes/perforated-plastic":11,"./material/classes/plastic":12,"./objectives/objectives/da":15,"./objectives/objectives/df":16,"./objectives/objectives/lux":17,"./objectives/objectives/sky_visibility":18,"./objectives/objectives/udi":19,"dup":1}]},{},[5])(5)
});