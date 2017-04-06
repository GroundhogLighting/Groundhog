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
//# sourceMappingURL=utilities.js.map