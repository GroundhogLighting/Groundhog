import Utilities = require('../Utilities');
import { Response } from '../core';

export = class LuminairesModule {

    luminaires: any;

    constructor(){
        
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

        this.updateList("");
    } // END OF CONSTRUCTOR

        
    useLuminaire = (name: string) => {
        let msg = this.luminaires[name];
        msg["name"] = name;
        Utilities.sendAction("use_luminaire",JSON.stringify(msg));
    };


    deleteLuminaire = (name: string) => {
        alert("Deleting "+name);
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
        for (let luminaire of this.luminaires) {
            let desc = luminaire.luminaire;
            let manufacturer = luminaire.manufacturer;
            let lamp = luminaire.lamp;
            if (   
                    luminaire.name.toLowerCase().indexOf(filter) >= 0 || 
                    manufacturer.toLowerCase().indexOf(filter) >= 0 ||
                    lamp.toLowerCase().indexOf(filter) >= 0 
                ) {                                
                    html = html + "<tr><td class='luminaire-name' name=\"" + luminaire.name + "\">" + luminaire.name + "</td><td>" + manufacturer + "</td><td>"+lamp+"</td></tr>" 
                    //<td class='icons'><span name=\"" + luminaire + "\" class='ui-icon ui-icon-trash del-luminaire'></span><span class='ui-icon ui-icon-pencil'></span></td>
            }        
        }
        list.html(html);

        $("td.luminaire-name").on("click", function () {
            let name = $(this).attr("name");
            this.useLuminaire(name);
        });


        $("span.del-luminaire").on("click", function () {
            let name = $(this).attr("name");
            this.deleteLuminaire(name);
        });
    }
}