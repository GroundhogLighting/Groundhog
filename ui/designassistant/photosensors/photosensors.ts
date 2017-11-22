import Utilities = require('../Utilities');
import { Response } from '../../common/core';
//import * as $ from 'jquery'
export = class PhotosensorsModule  {

    photosensors: any;
    addPhotosensorDialog: any;

    constructor (){
         
        
        this.photosensors = {};

        let addSensor = this.addSensor;
        /*
        this.addPhotosensorDialog =  $("#add_photosensor_dialog").dialog({
            autoOpen: false,
            modal: true,
            buttons: {
                "Add photosensor": function(){ addSensor(true)},
                Cancel: function () {
                    Utilities.sendAction("disable_active_tool","");
                    $(this).dialog("close");                    
                }
            },
            height: 0.8 * $(window).height(),
            width: 0.6 * $(window).width()
        });
        */
        let updateList = this.updateList;
        $("#filter_photosensors").keyup(function () {
            updateList(this.value);
        });

        let addPhotosensorDialog = this.addPhotosensorDialog;
        let clearDialog = this.clearDialog;
        $("#add_photosensor_button").on("click", function () {   //button().
            clearDialog();               
            $("#photosensor_name").prop("disabled",false);                  
            Utilities.sendAction("enable_photosensor_tool","");     
            //addPhotosensorDialog.dialog("open");
        });

        $("#add_photosensor_dialog :input").on("change",function(){
            //if we are editing... then move the sensor
            if ($("#photosensor_name").prop("disabled")){
                addSensor(false);
            }
        })
               

        this.updateList("");


    }

    updateList = (filter: string) :void => {         
        let list = $("#photosensor_list");
        list.html("");
        if(Object.keys(this.photosensors).length == 0){
            $("<div class='center'><h4>There are no photosensors in your model...</h4></div>").appendTo(list);
            return;
        }
        filter = filter.toLowerCase();
        
       let html = "<tr><td>Name</td><td></td></tr>"
        
        for (let sensor_name in this.photosensors) {   
            let sensor = this.photosensors[sensor_name];                      
            if (    
                    sensor_name.toLowerCase().indexOf(filter) >= 0                    
                ) {  
                                              
                    html = html + "<tr><td class='photosensor-name' name=\"" + sensor_name + "\">" + sensor_name + "</td>"                
                    html = html + "<td class='icons'><span name=\"" + sensor_name + "\" class='ui-icon ui-icon-trash del-sensor'></span><span name=\""+sensor_name+"\" class='ui-icon ui-icon-pencil edit-sensor'></span></td>"
                    
                }        
        }
        html += "</tr>";
        list.html(html);

        

        let editSensor = this.editSensor;
         $("span.edit-sensor").on("click", function () {
            let name = $(this).attr("name");                              
            Utilities.sendAction("enable_photosensor_tool","");  
            editSensor(name);
        });

        

        let deleteSensor = this.deleteSensor;
        $("span.del-sensor").on("click", function () {
            let name = $(this).attr("name");
            deleteSensor(name);
        });
    
    }

    clearDialog = () :void => {
        $("#photosensor_name").val('');

        $("#photosensor_px").val("");
        $("#photosensor_py").val("");
        $("#photosensor_pz").val("");

        $("#photosensor_nx").val("");
        $("#photosensor_ny").val("");
        $("#photosensor_nz").val("");
    }

    deleteSensor = (name: string) : Response => {
        if(this.photosensors.hasOwnProperty(name)){
            delete this.photosensors[name];
            this.updateList("");
            Utilities.sendAction('remove_photosensor',name)
        }else{            
            alert("There is an error with the photosensor you are trying to remove!");
            return {success: false};
        }

        return { success: true};
    }

    editSensor = (name: string) : Response => {
        if(this.photosensors.hasOwnProperty(name)){
            let sensor = this.photosensors[name];
            $("#photosensor_name").val(name);
            $("#photosensor_name").prop("disabled",true);            

            $("#photosensor_px").val(sensor.px);
            $("#photosensor_py").val(sensor.py);
            $("#photosensor_pz").val(sensor.pz);

            $("#photosensor_nx").val(sensor.nx);
            $("#photosensor_ny").val(sensor.ny);
            $("#photosensor_nz").val(sensor.nz);
        }else{            
            alert("There is an error with the photosensor you are trying to edit!");
            return {success: false};
        }
        //this.addPhotosensorDialog.dialog("open");
        return {success:true}
    }

    addSensor = (close : boolean) : boolean =>{
        let name = $.trim($("#photosensor_name").val());       
        if(this.photosensors.hasOwnProperty(name) && ! $("#photosensor_name").prop("disabled")){
            let r = confirm("A photosensor with this name already exists. Do you want to replace it?");
            if(!r){
                return false;
            }
        }else if(name == ""){
            alert("Please insert a valid name for the photosensor");
            return false;
        }

        let ps : any = {
            name: name,

            px : $("#photosensor_px").val(),
            py : $("#photosensor_py").val(),
            pz : $("#photosensor_pz").val(),

            nx : $("#photosensor_nx").val(),
            ny : $("#photosensor_ny").val(),
            nz : $("#photosensor_nz").val(),
        }      
        for(let key in ps){
            if(key === "name"){
                continue;
            }
            
            if(ps[key] === "" || isNaN(ps[key])){
                alert("Please introduce a valid number for all inputs")
                return;
            }
        }  
        if  (     
                parseFloat(ps.nx) * parseFloat(ps.nx) + parseFloat(ps.ny) * parseFloat(ps.ny) + parseFloat(ps.nz) * parseFloat(ps.nz)  < 0.0000001
            ){
                alert("Invalid normal values. They can't be all zero'")
                return;
            }
        this.photosensors[name] = ps;
        if( close ){
            //this.addPhotosensorDialog.dialog("close");             
            Utilities.sendAction("disable_active_tool","");           
        }
        
        Utilities.sendAction("add_photosensor",JSON.stringify(ps))
        this.updateList("");
        return true;
    }


}