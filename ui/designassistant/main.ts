import * as $ from 'jquery'
import Utilities = require('./utilities');
import Material = require('./materials/materials');
import Location = require('./location/location');
import Objectives = require('./objectives/objectives');
import Luminaires = require('./luminaires/luminaires');
import Calculate = require('./calculate/calculate');
import Report = require('./report/report');
import Photosensors = require('./photosensors/photosensors');
import Observers = require('./observers/observers');

import Version = require('../common/version');

let debug = Version.toLowerCase() === "debug";

export = class DesignAssistant {
    
    materials : Object;
    location : Object;
    objectives : Object;
    luminaires : Object;
    calculate : Object;
    report : Object;
    photosensors: Object;
    observers: Object;

    constructor(){
        let MaterialsModule = new Material(debug);
        this.materials = MaterialsModule;

        let LocationModule = new Location(debug);
        this.location = LocationModule;
        
        let ObjectivesModule = new Objectives();
        this.objectives = ObjectivesModule;

        let CalculateModule = new Calculate();
        this.calculate = CalculateModule;

        let LuminairesModule = new Luminaires();
        this.luminaires = LuminairesModule; 

        let PhotosensorsModule = new Photosensors();
        this.photosensors = PhotosensorsModule;  
        
        let ObserversModule = new Observers();
        this.observers = ObserversModule;  
        
        let ReportModule = new Report();
        this.report = ReportModule;   
        
    }

    update = () : void => {
        Utilities.sendAction("on_load","msg");
    }

}



