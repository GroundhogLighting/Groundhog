(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.DesignAssistant = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
"use strict";
module.exports = 'debug';

},{}],2:[function(require,module,exports){
"use strict";
var Version = require("../common/version");
var Glass = require("./materials/classes/glass");
var Metal = require("./materials/classes/metal");
var PerforatedMetal = require("./materials/classes/perforated-metal");
var Plastic = require("./materials/classes/plastic");
var PerforatedPlastic = require("./materials/classes/perforated-plastic");
var Diffuser = require("./materials/classes/diffuser");
var Fabric = require("./materials/classes/fabric");
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
        var v = Version.toLowerCase();
        if (v === "web_dialog") {
            window.location.href = 'skp:' + action + '@' + msg;
            return;
        }
        if (v === "debug") {
            console.log('Action: ' + action + ' | msg: ' + msg);
            return;
        }
        alert("Unkown version " + Version);
        return;
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

},{"../common/version":1,"./materials/classes/diffuser":7,"./materials/classes/fabric":8,"./materials/classes/glass":9,"./materials/classes/metal":10,"./materials/classes/perforated-metal":11,"./materials/classes/perforated-plastic":12,"./materials/classes/plastic":13,"./objectives/objectives/da":16,"./objectives/objectives/df":17,"./objectives/objectives/lux":18,"./objectives/objectives/sky_visibility":19,"./objectives/objectives/udi":20}],3:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function CalculateModule() {
        $("#daylight_set_low_parameters").on("click", function () {
            $("#ray_tracing_parameters").val("-ab 4 -ad 1000 -lw 1e-3");
            $("#elux_ray_tracing_parameters").val("-ab 4 -ad 1000 -lw 1e-3");
            $("#dc_parameters").val("-ab 4 -ad 1000 -lw 1e-3");
        });
        $("#daylight_set_med_parameters").on("click", function () {
            $("#ray_tracing_parameters").val("-ab 7 -ad 3000 -lw 1e-4");
            $("#elux_ray_tracing_parameters").val("-ab 7 -ad 3000 -lw 1e-4");
            $("#dc_parameters").val("-ab 7 -ad 3000 -lw 1e-4");
        });
        $("#daylight_set_high_parameters").on("click", function () {
            $("#ray_tracing_parameters").val("-ab 9 -ad 9999 -lw 1e-5");
            $("#elux_ray_tracing_parameters").val("-ab 9 -ad 9999 -lw 1e-5");
            $("#dc_parameters").val("-ab 9 -ad 9999 -lw 1e-5");
        });
        $("#electric_set_low_parameters").on("click", function () {
            $("#elux_ray_tracing_parameters").val("-ab 4 -ad 1000 -lw 1e-3");
        });
        $("#electric_set_med_parameters").on("click", function () {
            $("#elux_ray_tracing_parameters").val("-ab 7 -ad 3000 -lw 1e-4");
        });
        $("#electric_set_high_parameters").on("click", function () {
            $("#elux_ray_tracing_parameters").val("-ab 9 -ad 9999 -lw 1e-5");
        });
        $("#tdd_set_low_parameters").on("click", function () {
            $("#tdd_daylight_parameters").val("-ab 3 -ad 512 -lw 1e-3");
            $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
            $("#tdd_view_parameters").val("-ab 3 -ad 512 -lw 1e-3");
        });
        $("#tdd_set_med_parameters").on("click", function () {
            $("#tdd_daylight_parameters").val("-ab 3 -ad 512 -lw 1e-3");
            $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
            $("#tdd_view_parameters").val("-ab 3 -ad 512 -lw 1e-3");
        });
        $("#tdd_set_high_parameters").on("click", function () {
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

},{"../Utilities":2}],4:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function LocationModule(debug) {
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

},{"../Utilities":2}],5:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function LuminairesModule(debug) {
        var _this = this;
        this.useLuminaire = function (name) {
            var msg = _this.luminaires[name];
            msg["name"] = name;
            Utilities.sendAction("use_luminaire", JSON.stringify(msg));
        };
        this.deleteLuminaire = function (name) {
            var msg = _this.luminaires[name];
            Utilities.sendAction("delete_luminaire", JSON.stringify(msg));
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
            for (var luminaire_name in _this.luminaires) {
                var luminaire = _this.luminaires[luminaire_name];
                var manufacturer = luminaire.manufacturer;
                var lamp = luminaire.lamp;
                if (luminaire.name.toLowerCase().indexOf(filter) >= 0 ||
                    manufacturer.toLowerCase().indexOf(filter) >= 0 ||
                    lamp.toLowerCase().indexOf(filter) >= 0) {
                    html = html + "<tr>" +
                        "<td class='luminaire-name' name=\"" + luminaire.name + "\">" + luminaire.name + "</td>" +
                        "<td>" + manufacturer + "</td>" +
                        "<td>" + lamp + "</td>" +
                        "<td name='" + luminaire_name + "'>"
                        + "<i name='" + luminaire_name + "' class='material-icons del-luminaire'>delete</i>"
                        + "</td>";
                    "</tr>";
                }
            }
            list.html(html);
            var useLuminaire = _this.useLuminaire;
            $("td.luminaire-name").on("click", function () {
                var name = $(this).attr("name");
                useLuminaire(name);
            });
            var deleteLuminaire = _this.deleteLuminaire;
            $("i.del-luminaire").on("click", function () {
                var name = $(this).attr("name");
                deleteLuminaire(name);
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
        if (debug) {
            this.luminaires = {
                "Luminaire 1": {
                    "name": "Luminaire 1",
                    "manufacturer": "ERCO",
                    "lamp": "13W"
                },
                "Luminaire 2": {
                    "name": "Luminaire 2",
                    "manufacturer": "Philips",
                    "lamp": "13W"
                },
                "Luminaire 3": {
                    "name": "Luminaire 3",
                    "manufacturer": "ERCO",
                    "lamp": "3W"
                }
            };
        }
        else {
            this.luminaires = {};
        }
        this.updateList($("#filter_luminaires").val());
    }
    return LuminairesModule;
}());

},{"../Utilities":2}],6:[function(require,module,exports){
"use strict";
var Utilities = require("./utilities");
var Material = require("./materials/materials");
var Location = require("./location/location");
var Objectives = require("./objectives/objectives");
var Luminaires = require("./luminaires/luminaires");
var Calculate = require("./calculate/calculate");
var Report = require("./report/report");
var Photosensors = require("./photosensors/photosensors");
var Observers = require("./observers/observers");
var Version = require("../common/version");
var debug = Version.toLowerCase() === "debug";
module.exports = (function () {
    function DesignAssistant() {
        this.update = function () {
            Utilities.sendAction("on_load", "msg");
        };
        var MaterialsModule = new Material(debug);
        this.materials = MaterialsModule;
        var LocationModule = new Location(debug);
        this.location = LocationModule;
        var ObjectivesModule = new Objectives(debug);
        this.objectives = ObjectivesModule;
        var CalculateModule = new Calculate();
        this.calculate = CalculateModule;
        var LuminairesModule = new Luminaires(debug);
        this.luminaires = LuminairesModule;
        var PhotosensorsModule = new Photosensors(debug);
        this.photosensors = PhotosensorsModule;
        var ObserversModule = new Observers();
        this.observers = ObserversModule;
        var ReportModule = new Report();
        this.report = ReportModule;
    }
    return DesignAssistant;
}());

},{"../common/version":1,"./calculate/calculate":3,"./location/location":4,"./luminaires/luminaires":5,"./materials/materials":14,"./objectives/objectives":15,"./observers/observers":21,"./photosensors/photosensors":22,"./report/report":23,"./utilities":24}],7:[function(require,module,exports){
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

},{}],8:[function(require,module,exports){
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

},{}],9:[function(require,module,exports){
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

},{}],10:[function(require,module,exports){
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

},{}],11:[function(require,module,exports){
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

},{}],12:[function(require,module,exports){
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

},{}],13:[function(require,module,exports){
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

},{}],14:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function MaterialModule(debug) {
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
            for (var material_name in _this.materials) {
                var material = _this.materials[material_name];
                var cl = Utilities.getMaterialType(material["class"]);
                if (material.name.toLowerCase().indexOf(filter) >= 0 || cl.name.toLowerCase().indexOf(filter) >= 0) {
                    var r = material["color"][0];
                    var g = material["color"][1];
                    var b = material["color"][2];
                    var color = "rgb(" + Math.round(r) + "," + Math.round(g) + "," + Math.round(b) + ")";
                    html = html
                        + "<tr>"
                        + "<td name='" + material_name + "' class='mat-name'>" + material_name + "</td>"
                        + "<td name='" + material_name + "' class='mat-name'>" + cl.name + "</td>"
                        + "<td name='" + material_name + "' class='mat-name color' style='background: " + color + "'></td>"
                        + "<td name='" + material_name + "'>"
                        + "<i name='" + material_name + "' class='material-icons edit-material'>mode_edit</i>"
                        + "<i name='" + material_name + "' class='material-icons del-material'>delete</i>"
                        + "</td>"
                        + "</tr>";
                }
            }
            list.html(html);
            var useMaterial = _this.useMaterial;
            $("td.mat-name").on("click", function () {
                var name = $(this).attr("name");
                useMaterial(name);
            });
            var deleteMaterial = _this.deleteMaterial;
            $("i.del-material").on("click", function () {
                var name = $(this).attr("name");
                deleteMaterial(name);
            });
            var editMaterial = _this.editMaterial;
            $("i.edit-material").on("click", function () {
                var name = $(this).attr("name");
                editMaterial(name);
                openDialog("add_material_dialog");
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
            var su_color = { r: 200, g: 200, b: 200 };
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
            _this.updateList($("#filter_materials").val());
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
                var type = Utilities.getMaterialType(cl);
                type.parse(material);
            }
            else {
                alert("There is an error with the material you are trying to edit!");
                return { success: false };
            }
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
            _this.updateList($("#filter_materials").val());
            Utilities.sendAction("add_material", JSON.stringify(mat));
            return true;
        };
        var addMaterial = this.addMaterial;
        this.addMaterialDialog = $("#add_material_dialog");
        setOnSubmit(this.addMaterialDialog, addMaterial);
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
        $("#add_material_button").on("click", function () {
            $("#material_name").val("");
            $("#material_name").removeAttr("disabled");
            openDialog("add_material_dialog");
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
        if (debug) {
            this.materials = {
                "material 1": {
                    name: "material 1",
                    color: [1, 45, 121],
                    alpha: 1,
                    class: "Plastic",
                    rad: "void plastic %MAT_NAME% 0 0 5 0 0 0 0 0",
                    support_files: []
                },
                "material 2": {
                    name: "material 2",
                    color: [200, 100, 200],
                    alpha: 1,
                    class: "Plastic",
                    rad: "void plastic %MAT_NAME% 0 0 5 0 0 0 0 0",
                    support_files: []
                }
            };
        }
        else {
            this.materials = {};
        }
        this.updateList($("#filter_materials").val());
    }
    return MaterialModule;
}());

},{"../Utilities":2}],15:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
var Lux = require("./objectives/lux");
var DF = require("./objectives/df");
var UDI = require("./objectives/udi");
var DA = require("./objectives/da");
var SkyVisibility = require("./objectives/sky_visibility");
module.exports = (function () {
    function ObjectivesModule(debug) {
        var _this = this;
        this.metrics = [Lux, DF, UDI, DA, SkyVisibility];
        this.addObjective = function (wp_name, obj_name) {
            var message = { "workplane": wp_name, "objective": obj_name };
            Utilities.sendAction("add_objective", JSON.stringify(message));
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
            _this.updateList("");
            Utilities.sendAction("create_objective", JSON.stringify(objective));
            return { success: true };
        };
        this.removeObjective = function (workplane, objective) {
            Utilities.sendAction("remove_objective", JSON.stringify({ "workplane": workplane, "objective": objective }));
        };
        this.adapt_objective_dialog = function (metric_name) {
            var metric = Utilities.getObjectiveType(metric_name);
            $("#create_objective_dialog").children().hide();
            $("#objective_good_pixel").hide();
            $("label[for='objective_good_pixel']").hide();
            $("#objectiveName_field").show();
            $("#metric_field").show();
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
        };
        this.get_objective_object = function (metric_name) {
            var ret = {};
            ret["name"] = $.trim($("#objectiveName").val());
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
        this.editWorkplane = function (workplaneName) {
            console.log("About to edit workplane " + workplaneName);
            return { success: true };
        };
        this.updateList = function (filter) {
            filter = filter.toLowerCase();
            var list = $("#objectives_list");
            list.html("");
            if (Object.keys(_this.objectives).length == 0) {
                $("<div class='center'><h4>There are no objectives in your model...</h4></div>").appendTo(list);
                return;
            }
            var objectives = $("<tr></tr>");
            objectives.append($("<td></td>"));
            var _loop_2 = function (objectiveName) {
                if (_this.objectives.hasOwnProperty(objectiveName)) {
                    if (objectiveName.toLowerCase().indexOf(filter) >= 0) {
                        var td = $(("<td name='" + objectiveName + "'>" + objectiveName + "</td>"));
                        objectives.append(td);
                        var checkBox = $("<input type='checkbox' name='" + objectiveName + "'>");
                        var editButton = $("<i name='" + objectiveName + "' class='material-icons edit-material'>mode_edit</i>");
                        var deleteButton = $("<i name='" + objectiveName + "' class='material-icons edit-material'>delete</i>");
                        td.append(checkBox);
                        td.append(deleteButton);
                        td.append(editButton);
                        checkBox.click(function () {
                            console.log("check | uncheck whole objective");
                        });
                        deleteButton.click(function () {
                            var objectiveName = $(this).attr("name");
                            Utilities.sendAction("delete_objective", objectiveName);
                        });
                        var editObjective_1 = _this.editObjective;
                        editButton.click(function () {
                            var objectiveName = $(this).attr("name");
                            editObjective_1(objectiveName);
                        });
                        objectives.append(td);
                    }
                }
            };
            for (var objectiveName in _this.objectives) {
                _loop_2(objectiveName);
            }
            list.append(objectives);
            var _loop_3 = function (workplaneName) {
                if (_this.workplanes.hasOwnProperty(workplaneName)) {
                    if (workplaneName.toLowerCase().indexOf(filter) >= 0) {
                        var tr_1 = $("<tr></tr>");
                        var td_1 = $(("<td name='" + workplaneName + "'>" + workplaneName + "</td>"));
                        tr_1.append(td_1);
                        var checkBox = $("<input type='checkbox' name='" + workplaneName + "'>");
                        var editButton = $("<i name='" + workplaneName + "' class='material-icons edit-material'>mode_edit</i>");
                        var deleteButton = $("<i name='" + workplaneName + "' class='material-icons edit-material'>delete</i>");
                        td_1.append(checkBox);
                        td_1.append(deleteButton);
                        td_1.append(editButton);
                        checkBox.click(function () {
                            console.log("check | uncheck whole workplane");
                        });
                        deleteButton.click(function () {
                            var workplaneName = $(this).attr("name");
                            Utilities.sendAction("delete_workplane", workplaneName);
                        });
                        var editWorkplane_1 = _this.editWorkplane;
                        editButton.click(function () {
                            var workplaneName = $(this).attr("name");
                            editWorkplane_1(workplaneName);
                        });
                        tr_1.append(td_1);
                        var a_1 = _this.workplanes[workplaneName];
                        objectives.children("td").each(function () {
                            var obj = $(this);
                            var objName = $(this).attr("name");
                            if (objName !== undefined) {
                                console.log(objName);
                                td_1 = $("<td></td>");
                                var check = $("<input type='checkbox' id='" + workplaneName + "|||" + objName + "'>");
                                var label = $("<label for='" + workplaneName + "|||" + objName + "'></label>");
                                if (a_1.indexOf(objName) > -1) {
                                    check.prop('checked', true);
                                }
                                else {
                                    check.prop('checked', false);
                                }
                                check.click(function () {
                                    var name = $(this).attr("id").split("|||");
                                    var msg = { workplane: name[0], objective: name[1] };
                                    if ($(this).is(':checked')) {
                                        Utilities.sendAction("add_objective_to_workplane", JSON.stringify(msg));
                                    }
                                    else {
                                        Utilities.sendAction("delete_objective_from_workplane", JSON.stringify(msg));
                                    }
                                });
                                td_1.append(check);
                                td_1.append(label);
                                tr_1.append(td_1);
                            }
                        });
                        list.append(tr_1);
                    }
                }
            };
            for (var workplaneName in _this.workplanes) {
                _loop_3(workplaneName);
            }
        };
        this.parseObjective = function (obj) {
            _this.adapt_objective_dialog(obj.metric);
            $("#metric").val(obj["metric"]);
            $("#objectiveName").val(obj.name);
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
        this.editObjective = function (objectiveName) {
            $("#objectiveName").prop("disabled", true);
            var obj = _this.objectives[objectiveName];
            var metric = Utilities.getObjectiveType(obj["metric"]);
            _this.parseObjective(obj);
            openDialog("add_objective_dialog");
        };
        if (debug) {
            this.objectives = {
                "DA(300,50%)": {
                    "name": "UDI(300-3000,50%)",
                    "metric": "DA",
                    "dynamic": true,
                    "good_pixel": 50,
                    "good_light": { "min": 300, "max": null },
                    "goal": 50, "occupied": { "min": 8, "max": 18 }, "sim_period": { "min": 1, "max": 12 }
                },
                "UDI(300-3000,50%)": {
                    "name": "UDI(300-3000,50%)",
                    "metric": "UDI",
                    "dynamic": true,
                    "good_pixel": 50,
                    "good_light": { "min": 300, "max": 3000 },
                    "goal": 50, "occupied": { "min": 8, "max": 18 }, "sim_period": { "min": 1, "max": 12 }
                },
                "DF 10%": {
                    "name": "DF 10%",
                    "metric": "DF",
                    "dynamic": false,
                    "good_pixel": 50,
                    "good_light": { "min": 300, "max": 3000 },
                    "goal": 50, "occupied": { "min": 8, "max": 18 }, "sim_period": { "min": 1, "max": 12 }
                }
            };
            this.workplanes = {
                "Basement": [],
                "1st Floor": [
                    "DA(300,50%)", "DF 10%"
                ]
            };
        }
        else {
            this.objectives = {};
            this.workplanes = {};
        }
        var create_objective = this.create_objective;
        this.add_objective_dialog = $("#create_objective_dialog");
        setOnSubmit(this.add_objective_dialog, create_objective);
        var adapt_objective_dialog = this.adapt_objective_dialog;
        $("#metric").on("change", function () {
            adapt_objective_dialog(this.value);
        });
        var add_objective_dialog = this.add_objective_dialog;
        $("#create_objective_button").on("click", function () {
            $("#objectiveName").removeAttr("disabled");
            openDialog("create_objective_dialog");
        });
        for (var _i = 0, _a = this.metrics; _i < _a.length; _i++) {
            var metric = _a[_i];
            $('#metric').append($('<option>', {
                value: metric.metric,
                text: metric.name
            }));
        }
        this.adapt_objective_dialog(this.metrics[0].metric);
        var updateList = this.updateList;
        $("#objectives_filter").keyup(function () {
            updateList(this.value);
        });
        this.updateList("");
    }
    return ObjectivesModule;
}());

},{"../Utilities":2,"./objectives/da":16,"./objectives/df":17,"./objectives/lux":18,"./objectives/sky_visibility":19,"./objectives/udi":20}],16:[function(require,module,exports){
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

},{}],17:[function(require,module,exports){
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

},{}],18:[function(require,module,exports){
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

},{}],19:[function(require,module,exports){
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

},{}],20:[function(require,module,exports){
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

},{}],21:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function ObserversModule() {
        var _this = this;
        this.updateList = function (filter) {
            var list = $("#observer_list");
            list.html("");
            if (Object.keys(_this.observers).length == 0) {
                $("<div class='center'><h4>There are no observers in your model...</h4></div>").appendTo(list);
                return;
            }
            filter = filter.toLowerCase();
            var html = "<tr><td>Name</td><td></td></tr>";
            for (var observer_name in _this.observers) {
                console.log("aa");
                var observer = _this.observers[observer_name];
                if (observer_name.toLowerCase().indexOf(filter) >= 0) {
                    html = html + "<tr><td class='observer-name' name=\"" + observer_name + "\">" + observer_name + "</td>";
                    html = html + "<td class='icons'><span name=\"" + observer_name + "\" class='ui-icon ui-icon-trash del-observer'></span><span name=\"" + observer_name + "\" class='ui-icon ui-icon-pencil edit-observer'></span><span name=\"" + observer_name + "\" class='ui-icon ui-icon-circle-zoomin view-observer'></span></td>";
                }
            }
            html += "</tr>";
            list.html(html);
            var editObserver = _this.editObserver;
            $("span.edit-observer").on("click", function () {
                var name = $(this).attr("name");
                editObserver(name);
            });
            var deleteObserver = _this.deleteObserver;
            $("span.del-observer").on("click", function () {
                var name = $(this).attr("name");
                deleteObserver(name);
            });
            var viewObserver = _this.viewObserver;
            $("span.view-observer").on("click", function () {
                var name = $(this).attr("name");
                viewObserver(name);
            });
        };
        this.clearDialog = function () {
            $("#observer_name").val('');
            $("#observer_px").val("");
            $("#observer_py").val("");
            $("#observer_pz").val("");
            $("#observer_nx").val("");
            $("#observer_ny").val("");
            $("#observer_nz").val("");
        };
        this.deleteObserver = function (name) {
            if (_this.observers.hasOwnProperty(name)) {
                delete _this.observers[name];
                _this.updateList("");
                Utilities.sendAction('remove_observer', name);
            }
            else {
                alert("There is an error with the observer you are trying to remove!");
                return { success: false };
            }
            return { success: true };
        };
        this.editObserver = function (name) {
            if (_this.observers.hasOwnProperty(name)) {
                var observer = _this.observers[name];
                $("#observer_name").val(name);
                $("#observer_name").prop("disabled", true);
                $("#observer_px").val(observer.px);
                $("#observer_py").val(observer.py);
                $("#observer_pz").val(observer.pz);
                $("#observer_nx").val(observer.nx);
                $("#observer_ny").val(observer.ny);
                $("#observer_nz").val(observer.nz);
            }
            else {
                alert("There is an error with the observer you are trying to edit!");
                return { success: false };
            }
            _this.addObserverDialog.dialog("open");
            return { success: true };
        };
        this.addObserver = function () {
            var name = $.trim($("#observer_name").val());
            if (_this.observers.hasOwnProperty(name)) {
                var r = confirm("A observer with this name already exists. Do you want to replace it?");
                if (!r) {
                    return false;
                }
            }
            else if (name == "") {
                alert("Please insert a valid name for the observer");
                return false;
            }
            var ps = {
                name: name,
                px: $("#observer_px").val(),
                py: $("#observer_py").val(),
                pz: $("#observer_pz").val(),
                nx: $("#observer_nx").val(),
                ny: $("#observer_ny").val(),
                nz: $("#observer_nz").val(),
            };
            _this.observers[name] = ps;
            _this.addObserverDialog.dialog("close");
            Utilities.sendAction("addObserver", JSON.stringify(ps));
            _this.updateList("");
            return true;
        };
        this.viewObserver = function (name) {
            if (_this.observers.hasOwnProperty(name)) {
                var observer = _this.observers[name];
                Utilities.sendAction("go_to_view", JSON.stringify(observer));
            }
            else {
                alert("There is an error with the observer you are trying to view!");
                return { success: false };
            }
        };
        this.observers = {};
        var addObserver = this.addObserver;
        var updateList = this.updateList;
        $("#filter_observers").keyup(function () {
            updateList(this.value);
        });
        var addObserverDialog = this.addObserverDialog;
        var clearDialog = this.clearDialog;
        $("#add_observer_button").on("click", function () {
            clearDialog();
            $("#observer_name").prop("disabled", false);
        });
        this.updateList("");
    }
    return ObserversModule;
}());

},{"../Utilities":2}],22:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function PhotosensorsModule(debug) {
        var _this = this;
        this.updateList = function (filter) {
            var list = $("#photosensor_list");
            list.html("");
            if (Object.keys(_this.photosensors).length == 0) {
                $("<div class='center'><h4>There are no photosensors in your model...</h4></div>").appendTo(list);
                return;
            }
            filter = filter.toLowerCase();
            var html = "<tr><td>Name</td><td></td></tr>";
            for (var sensor_name in _this.photosensors) {
                var sensor = _this.photosensors[sensor_name];
                if (sensor_name.toLowerCase().indexOf(filter) >= 0) {
                    html = html + "<tr>" +
                        "<td class='photosensor-name' name=\"" + sensor_name + "\">" + sensor_name + "</td>"
                        + "<td name='" + sensor_name + "'>"
                        + "<i name='" + sensor_name + "' class='material-icons edit-sensor'>mode_edit</i>"
                        + "<i name='" + sensor_name + "' class='material-icons del-sensor'>delete</i>"
                        + "</td>"
                        + "</tr>";
                }
            }
            "</tr>";
            list.html(html);
            var editSensor = _this.editSensor;
            $("i.edit-sensor").on("click", function () {
                var name = $(this).attr("name");
                Utilities.sendAction("enable_photosensor_tool", "");
                editSensor(name);
            });
            var deleteSensor = _this.deleteSensor;
            $("i.del-sensor").on("click", function () {
                var name = $(this).attr("name");
                deleteSensor(name);
            });
        };
        this.clearDialog = function () {
            $("#photosensor_name").val('');
            $("#photosensor_px").val("");
            $("#photosensor_py").val("");
            $("#photosensor_pz").val("");
            $("#photosensor_nx").val("");
            $("#photosensor_ny").val("");
            $("#photosensor_nz").val("");
        };
        this.deleteSensor = function (name) {
            if (_this.photosensors.hasOwnProperty(name)) {
                delete _this.photosensors[name];
                _this.updateList("");
                Utilities.sendAction('remove_photosensor', name);
            }
            else {
                alert("There is an error with the photosensor you are trying to remove!");
                return { success: false };
            }
            return { success: true };
        };
        this.editSensor = function (name) {
            if (_this.photosensors.hasOwnProperty(name)) {
                var sensor = _this.photosensors[name];
                $("#photosensor_name").val(name);
                $("#photosensor_name").prop("disabled", true);
                $("#photosensor_px").val(sensor.px);
                $("#photosensor_py").val(sensor.py);
                $("#photosensor_pz").val(sensor.pz);
                $("#photosensor_nx").val(sensor.nx);
                $("#photosensor_ny").val(sensor.ny);
                $("#photosensor_nz").val(sensor.nz);
            }
            else {
                alert("There is an error with the photosensor you are trying to edit!");
                return { success: false };
            }
            return { success: true };
        };
        this.addSensor = function (close) {
            var name = $.trim($("#photosensor_name").val());
            if (_this.photosensors.hasOwnProperty(name) && !$("#photosensor_name").prop("disabled")) {
                var r = confirm("A photosensor with this name already exists. Do you want to replace it?");
                if (!r) {
                    return false;
                }
            }
            else if (name == "") {
                alert("Please insert a valid name for the photosensor");
                return false;
            }
            var ps = {
                name: name,
                px: $("#photosensor_px").val(),
                py: $("#photosensor_py").val(),
                pz: $("#photosensor_pz").val(),
                nx: $("#photosensor_nx").val(),
                ny: $("#photosensor_ny").val(),
                nz: $("#photosensor_nz").val(),
            };
            for (var key in ps) {
                if (key === "name") {
                    continue;
                }
                if (ps[key] === "" || isNaN(ps[key])) {
                    alert("Please introduce a valid number for all inputs");
                    return;
                }
            }
            if (parseFloat(ps.nx) * parseFloat(ps.nx) + parseFloat(ps.ny) * parseFloat(ps.ny) + parseFloat(ps.nz) * parseFloat(ps.nz) < 0.0000001) {
                alert("Invalid normal values. They can't be all zero'");
                return;
            }
            _this.photosensors[name] = ps;
            if (close) {
                Utilities.sendAction("disable_active_tool", "");
            }
            Utilities.sendAction("add_photosensor", JSON.stringify(ps));
            _this.updateList("");
            return true;
        };
        this.photosensors = {};
        var addSensor = this.addSensor;
        $("#add_photosensor_button").on("click", function () {
            openDialog("add_photosensor_dialog");
        });
        this.addPhotosensorDialog = $("#add_photosensor_dialog");
        setOnSubmit(this.addPhotosensorDialog, function () {
            addSensor(true);
            Utilities.sendAction("disable_active_tool", "");
        });
        setOnCancel(this.addPhotosensorDialog, function () {
            Utilities.sendAction("disable_active_tool", "");
        });
        var updateList = this.updateList;
        $("#filter_photosensors").keyup(function () {
            updateList(this.value);
        });
        var addPhotosensorDialog = this.addPhotosensorDialog;
        var clearDialog = this.clearDialog;
        $("#add_photosensor_button").on("click", function () {
            clearDialog();
            $("#photosensor_name").prop("disabled", false);
            Utilities.sendAction("enable_photosensor_tool", "");
        });
        $("#add_photosensor_dialog :input").on("change", function () {
            if ($("#photosensor_name").prop("disabled")) {
                addSensor(false);
            }
        });
        if (debug) {
            this.photosensors = {
                "Sensor 1": {},
                "Sensor 2": {},
                "Sensor 3": {}
            };
        }
        else {
            this.photosensors = {};
        }
        this.updateList($("#filter_photosensors").val());
    }
    return PhotosensorsModule;
}());

},{"../Utilities":2}],23:[function(require,module,exports){
"use strict";
var Utilities = require("../Utilities");
var DesignAssistant = {
    objectives: {}
};
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

},{"../Utilities":2}],24:[function(require,module,exports){
arguments[4][2][0].apply(exports,arguments)
},{"../common/version":1,"./materials/classes/diffuser":7,"./materials/classes/fabric":8,"./materials/classes/glass":9,"./materials/classes/metal":10,"./materials/classes/perforated-metal":11,"./materials/classes/perforated-plastic":12,"./materials/classes/plastic":13,"./objectives/objectives/da":16,"./objectives/objectives/df":17,"./objectives/objectives/lux":18,"./objectives/objectives/sky_visibility":19,"./objectives/objectives/udi":20,"dup":2}]},{},[6])(6)
});