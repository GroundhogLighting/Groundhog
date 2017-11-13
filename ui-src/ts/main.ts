
import Utilities = require('./utilities');
import Material = require('./materials/module');
import Location = require('./location/module');
import Objectives = require('./objectives/module');
import Luminaires = require('./luminaires/module');
import Calculate = require('./calculate/module');
import Report = require('./report/module');
import Photosensors = require('./photosensors/module');
import Observers = require('./observers/module');

export = class DesignAssistant {
    
    materials : any;
    location : any;
    objectives : any;
    luminaires : any;
    calculate : any;
    report : any;
    photosensors: any;
    observers: any;

    constructor(){
        let MaterialsModule = new Material();
        this.materials = MaterialsModule;

        let LocationModule = new Location();
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
        
        let ReportModule = new Report(this);
        this.report = ReportModule;   
        
    }

    update = () : void => {
        Utilities.sendAction("on_load","msg");
    }

}



