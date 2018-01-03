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
//# sourceMappingURL=main.js.map