import Version = require('../common/version');

import { MaterialType } from './materials/definitions';
import Glass = require('./materials/classes/glass');
import Metal = require('./materials/classes/metal');
import PerforatedMetal = require('./materials/classes/perforated-metal');
import Plastic = require('./materials/classes/plastic');
import PerforatedPlastic = require('./materials/classes/perforated-plastic');
import Diffuser = require('./materials/classes/diffuser');
import Fabric = require('./materials/classes/fabric');


import { ObjectiveType } from './objectives/definitions';
import Lux = require('./objectives/objectives/lux');
import DF = require('./objectives/objectives/df');
import UDI = require('./objectives/objectives/udi');
import DA = require('./objectives/objectives/da');
import SkyVisibility = require('./objectives/objectives/sky_visibility');


export = {
    
    fixName: function (name: string){
        return name.toLowerCase().replace(/\s/g, "_")
    },

    sendAction: function(action: string, msg: string){
        
        let v = Version.toLowerCase();

        if ( v === "web_dialog" ){
            window.location.href = 'skp:'+action+'@'+msg;
            return;
        }
        if ( v === "debug" ){
            console.log( 'Action: '+ action +' | msg: ' + msg );
            return;
        }
        alert("Unkown version " + Version);
        return;    
    },

    replaceAll: function (string: string, search: string, replacement: string) {        
        return string.replace(new RegExp(search, 'g'), replacement);
    },

      
    getMaterialType: function (cl: string) : MaterialType{
        cl = cl.toLowerCase();
        if ( cl === "plastic"){
            return Plastic;
        } 
        if ( cl === "metal" ){
            return Metal;
        } 
        if ( cl === "perforated metal" ){
            return PerforatedMetal;
        } 
        if ( cl === "perforated plastic" ){
            return PerforatedPlastic;
        }         
        if ( cl === "glass" ){
            return Glass;
        }                 
        if ( cl === "diffuser" ){
            return Diffuser;
        }
        if ( cl === "fabric"){
            return Fabric;
        }
        alert("Material Class not found at getMaterialType() in Utilities");
        return;
    },

    getObjectiveType: function (metric: string) : ObjectiveType{
        metric = metric.toLowerCase();
        if ( metric === "lux"){
            return Lux;
        }
        if ( metric === "da"){
            return DA;
        }
        if ( metric === "df"){
            return DF;
        }
        if ( metric === "udi"){
            return UDI;
        }
        if ( metric === "sky_visibility"){
            return SkyVisibility;
        }
        new RangeError("Objective class not fund at getObjectiveType() in Utilities");

    },

    findOne: function (array: Object[], cb: Function){
        for(let i=0; i<array.length; i++){
            if( cb(array[i]) ){
                return array[i];
            }
        }
    },

    capitalize: function(s : string){
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

}