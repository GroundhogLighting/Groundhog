//import * as $ from 'jquery';
import Utilities = require('../utilities');
import { Response } from '../core';
import { Material, MaterialType } from './definitions';

export = class MaterialModule  {

    materials: any;

    addMaterialDialog : any;
    
    

    constructor (){                    
                    let addMaterial = this.addMaterial;
                    this.addMaterialDialog = $("#add_material_dialog").dialog({
                                                autoOpen: false,
                                                modal: true,
                                                buttons: {
                                                    "Add material": addMaterial,
                                                    Cancel: function () {
                                                        $(this).dialog("close");
                                                    }
                                                },
                                                height: 0.9 * $(window).height(),
                                                width: 0.6 * $(window).width()
                                            });
                                                
                    let classes = ["Glass","Plastic","Metal","Perforated metal","Perforated plastic", "Diffuser", "Fabric"];

                    //Load materials in select
                    for (let i=0; i < classes.length; i++) {
                        let cl = classes[i];
                        $("#material_class").append($('<option>', {
                            value: cl,
                            text : cl
                        }));
                    }

                    this.adaptDialog(classes[0]);
                    let addMaterialDialog = this.addMaterialDialog;
                    $("#add_material_button").button().on("click", function () {
                        $("#material_name").val("");
                        $("#material_name").removeAttr("disabled");                        
                        addMaterialDialog.dialog("open");
                    });



                    $("#color_pick").spectrum({
                        preferredFormat: "hex3", showInput: true
                    });

                    let updateList = this.updateList;
                    $("#filter_materials").keyup(function () {
                        updateList(this.value);
                    });

                    let adaptDialog = this.adaptDialog;
                    $("#material_class").on("change", function () {
                        adaptDialog(this.value);
                    });



                    $("input.color").on("change", function () {
                        let r = parseFloat($("#red").val().replace(",","."));
                        let g = parseFloat($("#green").val().replace(",","."));
                        let b = parseFloat($("#blue").val().replace(",","."));
                        if($("#monochromatic").prop("checked")){
                            g=r; b=r;
                        }
                        $("#color_pick").spectrum("set", "rgb(" + Math.round(r*255) + "," + Math.round(g*255) + "," + Math.round(b*255) + ")");

                    });

                    $("#monochromatic").on("change",function(){
                        if($(this).prop("checked")){
                            $("#green").prop("disabled",true);
                            $("#blue").prop("disabled",true);
                            let red = $("#red").val();
                            $("#green").val(red);
                            $("#blue").val(red);
                        }else{
                            $("#green").removeAttr("disabled");
                            $("#blue").removeAttr("disabled");
                        }
                    });

                    $("#red").on("change",function(){
                        if($("#monochromatic").prop("checked")){
                            let red = $(this).val();
                            $("#green").val(red);
                            $("#blue").val(red);
                        }
                    });
           
                    $("#preview_button").on("click",function(){            
                        Utilities.sendAction('preview','msg');
                    });
                    this.materials=[];
                    this.updateList("");
    }

    updateList = ( filter: string ) :void => {
        filter = filter.toLowerCase();
        let list = $("#material_list");
        list.html("");
        if(Object.keys(this.materials).length == 0){
            $("<div class='center'><h4>There are no materials in your model...</h4></div>").appendTo(list);
            return;
        }
        let html = "<tr><td>Name</td><td>Class</td><td>Color</td><td></td></tr>"
        for (let material in this.materials) {
            if (this.materials.hasOwnProperty(material)) {
                let data = this.materials[material];
                let cl = Utilities.getMaterialType(data["class"]);
                if (material.toLowerCase().indexOf(filter) >= 0 || cl.name.toLowerCase().indexOf(filter) >= 0) {
                    let r = data["color"][0];
                    let g = data["color"][1];
                    let b = data["color"][2];
                    let color = "rgb(" + Math.round(r) + "," + Math.round(g) + "," + Math.round(b) + ")";
                    html = html + "<tr><td class='mat-name' name='" + material + "'>" + material + "</td><td class='mat-name' name='" + material + "'>" + cl.name + "</td><td name='" + material + "' class='color mat-name' style='background: " + color + "'></td><td class='icons'><span name=\"" + material + "\" class='ui-icon ui-icon-trash del-material'></span><span name=\"" + material + "\" class='ui-icon ui-icon-pencil edit-material'></span></td></tr>"
                }
            }
        }
        list.html(html);

        let useMaterial = this.useMaterial;
        $("td.mat-name").on("click", function () {
            let name = $(this).attr("name");
            useMaterial(name);
        });

        let deleteMaterial = this.deleteMaterial;
        $("span.del-material").on("click", function() {
            let name = $(this).attr("name");
            deleteMaterial(name);
        });

        let editMaterial = this.editMaterial;
        $("span.edit-material").on("click", function () {
            let name = $(this).attr("name");
            editMaterial(name);
        });
       
    }

    
    adaptDialog = ( c: string ) => {       
        let material = Utilities.getMaterialType(c);       
        $("#color_legend").text(material.color_property);        
        $("#other_material_properties").hide(); 
        let table = $("#other_material_properties_table");
        table.empty();       
        for(let input of material.inputs){
            if ( ["Red","Green","Blue"].indexOf(input.name) >= 0 ){
                $("#"+Utilities.fixName(input.name)).val(input.value);                
            }else{
                $("#other_material_properties").show();
                table.append("<tr><td>"+input.name+"</td><td><input type='number' min="+ input.min+" max="+ input.max+" step=0.01 id='material_"+Utilities.fixName(input.name)+"' value="+input.value+"></td></tr>");
            }                        
        }
    }

    get_material_json = () : Response => {
        let cl = Utilities.getMaterialType($("#material_class").val());

        //initialize
        let object:any = {};

        // add the class
        object["class"] = $("#material_class").val();

        // add the sketchup color
        let su_color = $("#color_pick").spectrum("get").toRgb();
        object["color"]=[su_color.r, su_color.g, su_color.b];

        //add the name
        object["name"] = $.trim($("#material_name").val());

        //get other inputs
        
        for(let input of cl.inputs){
            let id = "#"+Utilities.fixName(input.name); // if red, green or blue
            if(["Red","Green","Blue"].indexOf(input.name) < 0 ){ //if other
                id = "#material_"+Utilities.fixName(input.name);
            }            

            let i = parseFloat($(id).val().replace(",","."));
            if(i < input.min || i > input.max){
                alert("Please insert a valid number for "+input.name+" field");
                return {success:false};
            }   
            object[input.name] = i;
        }
        //extend and validate data
        object = cl.process(object);
        
        //create the return object
        let ret : Material = {
            name: object["name"],
            color: object["color"],
            alpha: object["alpha"],
            class: object["class"],
            rad: cl["rad"],
            support_files: [] //cl["support_files"]
        };
        
        //replace RAD and Support Files with the correct values.
        //Javascript was generating a pointer??... the actual this.classes was
        // modified when saying ret["support_files"] = cl["support_files"];
        if(cl.support_files && cl.support_files.length > 0){
            
            for(let file of cl.support_files){
                ret["support_files"].push({
                    "name" : file.name, 
                    "content": file.content
                });
            }
        }

        for (let input in object) {
            if (object.hasOwnProperty(input)) {
                ret["rad"] = Utilities.replaceAll(ret["rad"],"%"+Utilities.fixName(input)+"%",object[input])
                if(cl.support_files && cl.support_files.length > 0){
                    for(let i=0; i<cl.support_files.length; i++){
                        let s = ret["support_files"][i]["content"];
                        ret["support_files"][i]["content"] = Utilities.replaceAll(s,"%"+Utilities.fixName(input)+"%",object[input]);
                    }
                }
            }
        }
        return {success: true, object: ret}
    }

    deleteMaterial= ( materialName: string ) => {
        delete this.materials[materialName];
        this.updateList("");
        Utilities.sendAction('remove_material',materialName)
    }


    editMaterial= ( name: string) : Response => {
        if(this.materials.hasOwnProperty(name)){
            let material = this.materials[name];
            let cl = material["class"];
            this.adaptDialog(cl);
            $("#material_class").val(Utilities.capitalize(cl));  
            $("#material_name").prop("disabled",true);
            let rad = material["rad"].split(" ");
            $("#material_name").val(material["name"]);
            $("#color_pick").spectrum("set", "rgb(" + material["color"] [0]+ "," + material["color"] [1] + "," +material["color"] [2] + ")");            
            let type = Utilities.getMaterialType(cl);            
            type.parse(material);
        }else{
            alert("There is an error with the material you are trying to edit!");
            return {success: false};
        }

        this.addMaterialDialog.dialog("open");
        return {success: true};            
    }

    useMaterial = ( name: string ) : void => {
        let msg = this.materials[name];
        msg["name"] = name;
        Utilities.sendAction("use_material",JSON.stringify(msg));      
    }

    addMaterial = (): boolean => {
        let name = $.trim($("#material_name").val());       
        if(this.materials.hasOwnProperty(name)){
            let r = confirm("This material already exists. Do you want to replace it?");
            if(!r){
            return false;
            }
        }else if(name == ""){
            alert("Please insert a valid name for the material");
            return false;
        }
        let res: Response = this.get_material_json();


        if(!res.success){alert("!!!! "+res.error);return false}
        let mat = res.object;
        this.materials[name] = mat;
        this.updateList("");
        this.addMaterialDialog.dialog("close");
        Utilities.sendAction("add_material",JSON.stringify(mat));
    }
        
    
        
}
