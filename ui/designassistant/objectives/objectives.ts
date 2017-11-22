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

    constructor(){
        this.objectives = {};//{"DA(300,50%)":{"name":"DA(300,50%)","metric":"DA","dynamic":true,"good_pixel":50,"good_light":{"min":300,"max":null},"goal":50,"occupied":{"min":8,"max":18},"sim_period":{"min":1,"max":12}}};//{};
        this.workplanes ={};// {"Basement":[],"1st Floor":["DA(300,50%)"]}; //{};

        let create_objective = this.create_objective;
        /*
        this.add_objective_dialog =  $("#create_objective_dialog").dialog({
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
        let update_workplanes = this.update_workplanes;
        $("#workplane_objectives_filter").keyup(function () {
            update_workplanes(this.value);
        });

        let adapt_objective_dialog = this.adapt_objective_dialog;
        $("#metric").on("change", function () {
            adapt_objective_dialog(this.value);
        });

        let add_objective_dialog = this.add_objective_dialog;
        $("#create_objective_button").on("click", function () { //button().
            $("#objective_name").removeAttr("disabled");
            //add_objective_dialog.dialog("open");
        });

        //$("#objective_date_date").datepicker();

        let update_human_description = this.update_human_description;
        /*
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
        */

        $("#create_objective_dialog input").change(function(){
            update_human_description();
        });

        for (let metric of this.metrics) {            
            $('#metric').append($('<option>', {
                value: metric.metric,
                text : metric.name
            }));
        
        }


        this.adapt_objective_dialog(this.metrics[0].metric);
        let update_objectives = this.update_objectives;
        $("#objectives_filter").keyup(function () {
            update_objectives(this.value)
        });    

        this.update_objectives("");
        this.update_workplanes("");

    }// END OF CONSTRUCTOR

        

    add_objective = (wp_name : string, obj_name: string): void => {
        let message = { "workplane": wp_name, "objective": obj_name}//objectives[obj_name] };
        Utilities.sendAction("add_objective",JSON.stringify(message));
    };



    get_human_description = (metric: ObjectiveType) : string => {       
        let description = metric.human_language;
        let requirements = metric.requirements;
        //replace the data in the description
        for (let item of requirements) {          
            // get values
            if (item.value !== null && typeof item.value === 'object'){
                for (let sub_item_name in item.value) {
                    if (item.value.hasOwnProperty(sub_item_name)) {
                        description = Utilities.replaceAll(description,"%"+item.name+"_"+sub_item_name+"%",$("#objective_"+item.name+"_"+sub_item_name).val());
                    }
                }
            }else{
                description = Utilities.replaceAll(description,"%"+item.name+"%", $("#objective_"+item.name).val());
            }            
        }
        return description;
    };

    update_human_description = () : void => {
        //change human description
        let metric = $("#metric").val();   
        metric = Utilities.getObjectiveType(metric);
        $("#objective_human_description").text(this.get_human_description(metric));
    }

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
        this.update_objectives("");
        //this.add_objective_dialog.dialog("close");
        
        Utilities.sendAction("create_objective",JSON.stringify(objective));
        return { success: true }
    };



    remove_objective = (workplane: string, objective:string) => {
        Utilities.sendAction("remove_objective",JSON.stringify({ "workplane": workplane, "objective": objective }));
    };




    adapt_objective_dialog = (metric_name: string) => {
        
        let metric = Utilities.getObjectiveType(metric_name);

        // hide everything
        $("#create_objective_dialog").children().hide();
        $("#objective_good_pixel").hide();
        $("label[for='objective_good_pixel']").hide();

        //show the default things
        $("#objective_name_field").show();
        $("#metric_field").show();
        $("#compliance_field").show();
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
        this.update_human_description();
    };


    /* DATA VALIDATION IS DONE HERE */
    get_objective_object = (metric_name: string) : Response => {
        //get the requirements
        let ret: any = {};
        ret["name"] = $.trim($("#objective_name").val());
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


        
    update_objectives = (filter: string) => {
        let list = $("#objectives_list");
        list.html("");
        if (Object.keys(this.objectives).length == 0) {
            $("<div class='center'><h4>There are no objectives in your model...</h4></div>").appendTo(list);
            return;
        }
        filter = filter.toLowerCase();
        for (let objective in this.objectives) {
            if (this.objectives.hasOwnProperty(objective)) {
            if (objective.toLowerCase().indexOf(filter) >= 0) {//filter by objective name
                let new_row = $("<tr></tr>");
                let drag = $(("<td name='"+objective+"'>" + objective +"</td>"));
                new_row.append(drag); //
                let action_column = $("<td></td>");
                let delete_button = $("<span name=\"" + objective + "\" class='ui-icon ui-icon-trash del-material'></span>")
                let edit_button = $("<span name=\"" + objective + "\" class='ui-icon ui-icon-pencil edit-material'></span>")
                delete_button.on("click", function () {
                    let objective_name = $(this).attr("name");
                    Utilities.sendAction("delete_objective",objective_name);
                });
                let editObjective = this.editObjective;
                edit_button.on("click", function () {
                    let objective_name = $(this).attr("name");
                    editObjective(objective_name);
                });
                new_row.append(action_column);
                action_column.append(edit_button);
                action_column.append(delete_button);
                /*drag.draggable({
                    appendTo: "body",
                    helper: "clone"
                });
                */
                list.append(new_row)
            }
            }
        }
    }

    parseObjective = (obj: any) => {
        this.adapt_objective_dialog(obj.metric);
        $("#metric").val(obj["metric"]);
        $("#objective_name").val(obj.name);
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

    editObjective = (objective_name: string) => {
        $("#objective_name").prop("disabled",true);
        let obj = this.objectives[objective_name];
        let metric = Utilities.getObjectiveType(obj["metric"]);
        this.parseObjective(obj);        
        //this.add_objective_dialog.dialog("open");
    };

    

    
    get_new_row_for_workplane = (workplane: string, objective: string) => {
        let row = $("<tr></tr>");
        let name_column = $("<td>" + objective + "</td>");
        row.append(name_column);

        let actions_column = $("<td></td>");
        let delete_button = $("<span name='" + workplane + "' title='" + objective + "' class='ui-icon ui-icon-trash del-objective'></span>")
        let remove_objective = this.remove_objective;
        delete_button.on("click", function () {
            let wp = $(this).attr("name");
            let obj = $(this).parent().siblings("td").text();
            remove_objective(wp, obj);
        });
        actions_column.append(delete_button);
        row.append(actions_column);
        return row;
    }

    update_workplanes = (filter: string) : void => {
        let ul = $("#workplane_objectives"); ul.html("");

        if (Object.keys(this.workplanes).length === 0) {
            $("<div class='center'><h4>There are no workplanes in your model...</h4></div>").appendTo(ul);
            return;
        }
        filter = filter.toLowerCase();        
        let workplanes = this.workplanes;
        let add_objective = this.add_objective;
        let get_new_row_for_workplane = this.get_new_row_for_workplane;
        for (let wp_name in this.workplanes) {
            if (this.workplanes.hasOwnProperty(wp_name)) {
            if (wp_name.toLowerCase().indexOf(filter) >= 0) {//filter by workplane name
                //first, create the h3 header
                let li = $("<li></li>");
                let title = $("<h1></h1>");
                title.text(wp_name);
                li.append(title);

                /*
                li.droppable({
                    hoverClass: "hover",
                    accept: ":not(.ui-sortable-helper)",
                    drop: function(event: any, ui: any) {
                        if ("TD" != ui.draggable.prop("tagName")) { return };

                        let wp_name = $(this).find("h1").text();
                        let table_name = Utilities.fixName(wp_name) + "_objectives";
                        let objective = ui.draggable.attr("name");
                        //check if workplane already has the objective
                        if (workplanes[wp_name].indexOf(objective) >= 0) {
                            alert("That workplane has already been assigned that objective!")
                            return;
                        }
                        //add the objective visually to the UI
                        let new_row = get_new_row_for_workplane(wp_name, objective);
                        let table = $("#" + table_name);
                        if (table.length == 0) { // if the table does not exist
                            $(this).find("div").remove(); //remove the "drop here" tag
                            table = $("<table id='" + table_name + "'></table>"); // Create it
                            table.appendTo($(this)); //append it
                        }
                        //now we are sure it exists
                        new_row.appendTo(table);

                        //register the objective in the data structure
                        workplanes[wp_name].push(objective);

                        //pass the information to SketchUp
                        add_objective(wp_name,objective);
                    }
                });
                */
                ul.append(li);

                // Fill with objectives
                let objectives = this.workplanes[wp_name];
                if (objectives.length == 0) {
                li.append($("<div>Drop objectives here</div>"))
                li.addClass("empty");
                } else {
                let table = $("<table id='" + Utilities.fixName(wp_name) + "_objectives'>");
                for (let i = 0; i < objectives.length; i++) {
                    let row = this.get_new_row_for_workplane(wp_name, objectives[i]);
                    table.append(row);
                }
                li.append(table);
                }

            }
            }
        }
    }


}// END OF CLASS