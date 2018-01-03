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
//# sourceMappingURL=utilities.js.map