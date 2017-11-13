"use strict";
var Utilities = require("./utilities");
var Material = require("./materials/module");
var Location = require("./location/module");
var Objectives = require("./objectives/module");
var Luminaires = require("./luminaires/module");
var Calculate = require("./calculate/module");
var Report = require("./report/module");
var Photosensors = require("./photosensors/module");
var Observers = require("./observers/module");
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
        var LuminairesModule = new Luminaires();
        this.luminaires = LuminairesModule;
        var PhotosensorsModule = new Photosensors();
        this.photosensors = PhotosensorsModule;
        var ObserversModule = new Observers();
        this.observers = ObserversModule;
        var ReportModule = new Report(this);
        this.report = ReportModule;
    }
    return DesignAssistant;
}());
//# sourceMappingURL=main.js.map