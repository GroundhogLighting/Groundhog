//import * as $ from 'jquery'
import Utilities = require('../Utilities');
import { Response } from '../../common/core';

import { ObjectiveType } from './definitions';

import Lux = require('./objectives/lux');
import DF = require('./objectives/df');
import UDI = require('./objectives/udi');
import DA = require('./objectives/da');
import SkyVisibility = require('./objectives/sky_visibility');

export = class ObjectivesModule {

    add_objective_dialog: any;
    metrics = [Lux,DF,UDI,DA,SkyVisibility];
    objectives:any;
    workplanes: any;

    constructor(debug: boolean){
        if(debug){
            this.objectives = {
                "DA(300,50%)":{ 
                    "name":"UDI(300-3000,50%)",
                    "metric":"DA",
                    "dynamic":true,
                    "good_pixel":50,
                    "good_light":{"min":300,"max":null},
                    "goal":50,"occupied":{"min":8,"max":18},"sim_period":{"min":1,"max":12}
                },
                "UDI(300-3000,50%)":{ 
                    "name":"UDI(300-3000,50%)",
                    "metric":"UDI",
                    "dynamic":true,
                    "good_pixel":50,
                    "good_light":{"min":300,"max":3000},
                    "goal":50,"occupied":{"min":8,"max":18},"sim_period":{"min":1,"max":12}
                },
                "DF 10%":{ 
                    "name":"DF 10%",
                    "metric":"DF",
                    "dynamic":false,
                    "good_pixel":50,
                    "good_light":{"min":300,"max":3000},
                    "goal":50,"occupied":{"min":8,"max":18},"sim_period":{"min":1,"max":12}
                }
            };
            this.workplanes = {
                "Basement":[],
                "1st Floor":[
                    "DA(300,50%)","DF 10%"
                ]
            }; 

        }else{
            this.objectives = {};
            this.workplanes ={};
        }

        let create_objective = this.create_objective;
        this.add_objective_dialog =  $("#create_objective_dialog");
        setOnSubmit(this.add_objective_dialog,create_objective);
        /*
        .dialog({
            autoOpen: false,
            modal: true,
            buttons: {
                "Create objective": create_objective,
                Cancel: function () {
                    $(this).dialog("close");
                }
            },
            height: 0.8 * $(window).height(),
            width: 0.6 * $(window).width()
        });
        */


        //objectives....
        /*
        let update_workplanes = this.update_workplanes;
        $("#workplane_objectives_filter").keyup(function () {
            update_workplanes(this.value);
        });
*/
        let adapt_objective_dialog = this.adapt_objective_dialog;
        $("#metric").on("change", function () {
            adapt_objective_dialog(this.value);
        });

        let add_objective_dialog = this.add_objective_dialog;
        $("#create_objective_button").on("click", function () { //button().
            $("#objectiveName").removeAttr("disabled");
            openDialog("create_objective_dialog");
        });

        //$("#objective_date_date").datepicker();

        /*
        let update_human_description = this.update_human_description;
        $(".resizable1").resizable({
            autoHide: true,
            handles: 'e',
            resize: function (e:any, ui:any) {
                let parent = ui.element.parent();
                let remainingSpace = parent.width() - ui.element.outerWidth(),
                divTwo = ui.element.next(),
                divTwoWidth = (remainingSpace - divTwo.outerWidth() + divTwo.width()) / parent.width() * 98 + "%";
                divTwo.width(divTwoWidth);
            },
            stop: function (e:any, ui:any) {
            let parent = ui.element.parent();
            ui.element.css(
                {
                    width: ui.element.width() / parent.width() * 100 + "%",
                });
            }
        });
        
        $("#create_objective_dialog input").change(function(){
            update_human_description();
        });
        */
        
        for (let metric of this.metrics) {            
            $('#metric').append($('<option>', {
                value: metric.metric,
                text : metric.name
            }));
        
        }


        this.adapt_objective_dialog(this.metrics[0].metric);
        let updateList = this.updateList;
        $("#objectives_filter").keyup(function () {
            updateList(this.value)
        });    

        this.updateList("");        

    }// END OF CONSTRUCTOR

        

    addObjective = (wp_name : string, obj_name: string): void => {
        let message = { "workplane": wp_name, "objective": obj_name}//objectives[obj_name] };
        Utilities.sendAction("add_objective",JSON.stringify(message));
    };

    create_objective = () : Response => {
        let failure = { success: false }
        let metric = $("#metric").val();
        let res : Response = this.get_objective_object(metric); 
        if (!res.success) { alert(res.error); return failure; }
        let objective = res.object
        let name = objective["name"];
  
        if(this.objectives.hasOwnProperty(name)){
            let r = confirm("This objective already exists. Do you want to replace it?");
            if(!r){
                return failure;
            }
        }else if(name == ""){
            alert("Please insert a valid name for the objective");
            return failure;
        }
        this.objectives[name] = objective;
        this.updateList("");
        //this.add_objective_dialog.dialog("close");
        
        Utilities.sendAction("create_objective",JSON.stringify(objective));
        return { success: true }
    };



    removeObjective = (workplane: string, objective:string) => {
        Utilities.sendAction("remove_objective",JSON.stringify({ "workplane": workplane, "objective": objective }));
    };




    adapt_objective_dialog = (metric_name: string) => {
        
        let metric = Utilities.getObjectiveType(metric_name);

        // hide everything
        $("#create_objective_dialog").children().hide();
        $("#objective_good_pixel").hide();
        $("label[for='objective_good_pixel']").hide();

        //show the default things
        $("#objectiveName_field").show();
        $("#metric_field").show();
        //$("#compliance_field").show();
        $("#human_description").show();

        // Then, show only specific items that are needed.
        for (let item of metric.requirements) {          
            //unhide
            $("#objective_"+item.name).show();
            $("label[for='objective_"+item.name+"']").show();

            // set values
            if (item.value !== null && typeof item.value === 'object'){
                for (let sub_item_name in item.value) {
                    if (item.value.hasOwnProperty(sub_item_name)) {
                        let sub_item = item.value[sub_item_name];
                        $("#objective_"+item.name+"_"+sub_item_name).val(sub_item);
                    }
                }
            }else{
                let req:any = Utilities.findOne(metric.requirements,function(e:any){
                    return e.name === item.name
                });
                $("#objective_"+item.name).val(req.name);
            }
            
        }
        //change legend
        $("#objective_good_light_legend").text(metric.good_light_legend);
        //this.update_human_description();
    };


    /* DATA VALIDATION IS DONE HERE */
    get_objective_object = (metric_name: string) : Response => {
        //get the requirements
        let ret: any = {};
        ret["name"] = $.trim($("#objectiveName").val());
        ret["metric"] = metric_name;
        let metric = Utilities.getObjectiveType(metric_name);
        ret["dynamic"] = metric.dynamic;

        //retrieve corresponding data
        for (let item of metric.requirements) {
            // get values
            if (item.value !== null && typeof item.value === 'object'){
                ret[item.name]={};
                for (let sub_item_name in item.value) {
                    if (item.value.hasOwnProperty(sub_item_name)) {
                        let input = $("#objective_"+item.name+"_"+sub_item_name);
                        ret[item.name][sub_item_name] = input.val();
                        if(input.attr("type")==="number"){
                        ret[item.name][sub_item_name] = parseFloat(ret[item.name][sub_item_name]);
                        }
                    }
                }
            }else{
                ret[item.name] = parseFloat($("#objective_"+item.name).val());
            }
            
        }
        //change legend
        $("#objective_good_light_legend").text(metric.good_light_legend);
        return {success: true, object: ret};
    }

    editWorkplane = (workplaneName : string) : Response => {
        console.log("About to edit workplane "+ workplaneName);   
        return { success: true}     
    }

        
    updateList = (filter: string) => {

        filter = filter.toLowerCase();
        
        let list = $("#objectives_list");
        list.html("");
        if (Object.keys(this.objectives).length == 0) {
            $("<div class='center'><h4>There are no objectives in your model...</h4></div>").appendTo(list);
            return;
        }

        let objectives = $("<tr></tr>");
        objectives.append($("<td></td>"));
        // For each objective
        for (let objectiveName in this.objectives) {
            if (this.objectives.hasOwnProperty(objectiveName)) {
                //filter by objective name
                if (objectiveName.toLowerCase().indexOf(filter) >= 0) {                    

                    let td = $(("<td name='"+objectiveName+"'>" + objectiveName +"</td>"));
                    objectives.append(td); 

                    let checkBox = $("<input type='checkbox' name='"+objectiveName+"'>");
                    let editButton = $("<i name='" + objectiveName + "' class='material-icons edit-material'>mode_edit</i>");
                    let deleteButton = $("<i name='" + objectiveName + "' class='material-icons edit-material'>delete</i>")
                    
                    td.append(checkBox);
                    td.append(deleteButton);
                    td.append(editButton);

                    checkBox.click(function(){
                        console.log("check | uncheck whole objective");
                    })

                    deleteButton.click(function () {
                        let objectiveName = $(this).attr("name");
                        Utilities.sendAction("delete_objective",objectiveName);
                    });
                    
                    let editObjective = this.editObjective;
                    editButton.click(function () {
                        let objectiveName = $(this).attr("name");
                        editObjective(objectiveName);
                    });
                    
                    objectives.append(td);
                }
            }
        } // End iterating objectives

        list.append(objectives);

        // Iterate workplanes
        for (let workplaneName in this.workplanes) {
            if (this.workplanes.hasOwnProperty(workplaneName)) {
                //filter by objective name
                if (workplaneName.toLowerCase().indexOf(filter) >= 0) {
                    let tr = $("<tr></tr>");

                    // Add workplane name
                    let td = $(("<td name='"+workplaneName+"'>" + workplaneName +"</td>"));
                    tr.append(td); 

                    let checkBox = $("<input type='checkbox' name='"+workplaneName+"'>");
                    let editButton = $("<i name='" + workplaneName + "' class='material-icons edit-material'>mode_edit</i>");
                    let deleteButton = $("<i name='" + workplaneName + "' class='material-icons edit-material'>delete</i>")
                    
                    td.append(checkBox);
                    td.append(deleteButton);
                    td.append(editButton);


                    checkBox.click(function(){
                        console.log("check | uncheck whole workplane");
                    })

                    deleteButton.click(function () {
                        let workplaneName = $(this).attr("name");
                        Utilities.sendAction("delete_workplane",workplaneName);
                    });
                    
                    let editWorkplane = this.editWorkplane;
                    editButton.click(function () {
                        let workplaneName = $(this).attr("name");
                        editWorkplane(workplaneName);
                    });
                    
                    tr.append(td);

                    // Check the objectives.
                    let a = this.workplanes[workplaneName];
                    objectives.children("td").each(function(){
                        let obj = $(this);
                        let objName = $(this).attr("name");
                        if(objName !== undefined){                            
                            td = $("<td></td>");
                            let check = $("<input type='checkbox' id='"+workplaneName+"|||"+objName+"'>");
                            let label = $("<label for='"+workplaneName+"|||"+objName+"'></label>")
                            
                            
                            if(a.indexOf(objName) > -1){
                                check.prop('checked', true);
                            }else{
                                check.prop('checked', false);
                            }
                            
                            check.click(function(){
                                let name = $(this).attr("id").split("|||");
                                let msg = {workplane: name[0], objective: name[1]};
                                if($(this).is(':checked')){
                                    Utilities.sendAction("add_objective_to_workplane",JSON.stringify(msg));
                                }else{
                                    Utilities.sendAction("delete_objective_from_workplane",JSON.stringify(msg));
                                }
                            });
                            
                            td.append(check);
                            td.append(label);
                            tr.append(td);
                        }
                    });


                    list.append(tr);
                }
            }
        }
    }

    parseObjective = (obj: any) => {
        this.adapt_objective_dialog(obj.metric);
        $("#metric").val(obj["metric"]);
        $("#objectiveName").val(obj.name);
        let metric = Utilities.getObjectiveType(obj.metric);
        for (let item of metric.requirements) {             
            // get values
            if (item.value !== null && typeof item.value === 'object'){
                for (let sub_item_name in item.value) {
                    if (item.value.hasOwnProperty(sub_item_name)) {
                        $("#objective_"+item.name+"_"+sub_item_name).val(obj[item.name][sub_item_name]);
                    }
                }
            }else{
                $("#objective_"+item.name).val(obj[item.name]);
            }                
        }
    }

    editObjective = (objectiveName: string) => {
        $("#objectiveName").prop("disabled",true);
        let obj = this.objectives[objectiveName];
        let metric = Utilities.getObjectiveType(obj["metric"]);
        this.parseObjective(obj);        
        openDialog("add_objective_dialog");
    };


}// END OF CLASS