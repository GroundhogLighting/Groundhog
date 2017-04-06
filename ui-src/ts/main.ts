
import Utilities = require('./utilities');

import Material = require('./material/module');

import Location = require('./location/module');

import Objectives = require('./objectives/module');

import Luminaires = require('./luminaires/module');

import Calculate = require('./calculate/module');

import Report = require('./report/module');

export = class DesignAssistant {
    
    materials : any;
    location : any;
    objectives : any;
    luminaires : any;
    calculate : any;
    report : any;
    
    constructor(){
        let MaterialsModule = new Material();
        this.materials = MaterialsModule;

        let LocationModule = new Location();
        this.location = LocationModule;
        
        let ObjectivesModule = new Objectives();
        this.objectives = ObjectivesModule;

        let CalculateModule = new Calculate();
        this.calculate = CalculateModule;

        let ReportModule = new Report();
        this.report = ReportModule;   
        
        let LuminairesModule = new Luminaires();
        this.luminaires = LuminairesModule;    
    }

    update = () : void => {
        Utilities.sendAction("on_load","msg");
    }

}



