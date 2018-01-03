import Utilities = require('../Utilities');
import { Response } from '../../common/core';

//import * as $ from 'jquery'

export = class LuminairesModule {

    luminaires: any;

    constructor(debug: boolean){
        
        this.luminaires = {};

        let updateList = this.updateList;
        $("#filter_luminaires").keyup(function () {
            updateList(this.value);
        });

        $("#elux_preview").on("click",function(){
             Utilities.sendAction("preview","msg");
        })

        $("#elux_night_preview").on("click",function(){
            Utilities.sendAction("night_preview","msg")
        })


         /* INITIALIZE */
         if(debug){
            this.luminaires = {
                "Luminaire 1":{
                    "name": "Luminaire 1",
                    "manufacturer" : "ERCO",
                    "lamp" : "13W"
                }, 
                "Luminaire 2":{
                    "name": "Luminaire 2",
                    "manufacturer" : "Philips",
                    "lamp" : "13W"
                },
                "Luminaire 3":{
                    "name": "Luminaire 3",
                    "manufacturer" : "ERCO",
                    "lamp" : "3W"
                }            
        }
            
        }else{
            this.luminaires={};
        }
        this.updateList($("#filter_luminaires").val());
    } // END OF CONSTRUCTOR

        
    useLuminaire = (name: string) => {
        let msg = this.luminaires[name];
        msg["name"] = name;
        Utilities.sendAction("use_luminaire",JSON.stringify(msg));
    };


    deleteLuminaire = (name: string) => {
        let msg = this.luminaires[name];
        Utilities.sendAction("delete_luminaire",JSON.stringify(msg));
    };

    updateList = (filter : string) => {
        let list = $("#luminaire_list");
        list.html("");
        if(Object.keys(this.luminaires).length == 0){
            $("<div class='center'><h4>There are no luminaires in your model...</h4></div>").appendTo(list);
            return;
        }
        
        filter = filter.toLowerCase();
        
        let html = "<tr><td>Luminaire</td><td>Manufacturer</td><td>Lamp</td></tr>"
        for (let luminaire_name in this.luminaires) {
            let luminaire = this.luminaires[luminaire_name];   
            //let desc = luminaire.luminaire;
            let manufacturer = luminaire.manufacturer;
            let lamp = luminaire.lamp;

            if (   
                    luminaire.name.toLowerCase().indexOf(filter) >= 0 || 
                    manufacturer.toLowerCase().indexOf(filter) >= 0 ||
                    lamp.toLowerCase().indexOf(filter) >= 0 
                ) {                                
                    html = html + "<tr>"+
                        "<td class='luminaire-name' name=\"" + luminaire.name + "\">" + luminaire.name + "</td>"+
                        "<td>" + manufacturer + "</td>"+
                        "<td>"+lamp+"</td>"+
                        "<td name='" + luminaire_name + "'>"
                            +"<i name='" + luminaire_name + "' class='material-icons del-luminaire'>delete</i>"                        
                        +"</td>"                
                    "</tr>"; 
            }        
        }
        list.html(html);

        let useLuminaire = this.useLuminaire;
        $("td.luminaire-name").on("click", function () {
            let name = $(this).attr("name");
            useLuminaire(name);
        });

        let deleteLuminaire = this.deleteLuminaire;
        $("i.del-luminaire").on("click", function () {
            let name = $(this).attr("name");
            deleteLuminaire(name);
        });
    }
}