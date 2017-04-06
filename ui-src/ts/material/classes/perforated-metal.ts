//import * as $ from 'jquery';
import { Response } from '../../core';
import { MaterialType, Material } from '../definitions';
//import { Utilities } from '../../utilities';
import Utilities = require('../../utilities');

let PerforatedMetal: MaterialType = {
    
    name : "Perforated metal",
    inputs : [        
        {name: "Red", value: 0.6, min: 0, max: 1}, 
        {name: "Green", value: 0.6, min: 0, max: 1}, 
        {name: "Blue", value: 0.6, min: 0, max: 1}, 
        {name: "Specularity", value: 0.95, min: 0, max: 1}, 
        {name: "Roughness", value: 0.05, min: 0, max: 1},
        {name: "Transparency", value: 0.25, min: 0, max: 1}
    ],
    rad : "void metal %base_material_name% 0 0 5 %red% %green% %blue% %specularity% %roughness% void mixfunc %MAT_NAME% 4 void %base_material_name% transparency %funcfile% 0 0",
    support_files : [{name : "funcfile", content : "transparency = %transparency%;"}],
    color_property : "Base material reflectance",
    

    process: function(inputs:any):any{
        inputs["alpha"]=Math.sqrt(1-parseFloat(inputs["Transparency"]));
        if(inputs["alpha"] > 0.95){inputs["alpha"] = 0.95};
        inputs["base_material_name"] = inputs["name"].toLowerCase().replace(/\s/g, "_")+"_base_material";
        return inputs;
    },

    parse : function(material: Material): void {
        let rad = material["rad"];
        let data = rad.split(" ");
        $("#red").val(data[6]);
        $("#green").val(data[7]);
        $("#blue").val(data[8]);
        $("#material_specularity").val(data[9]);
        $("#material_roughness").val(data[10]);

        let support_files = material["support_files"];
        let funcfile = support_files[0]["content"].split(" = ");
        let transparency = parseFloat(funcfile[1].replace(new RegExp(";",'g'),""));
        $("#material_transparency").val(transparency);
    }

}

export = PerforatedMetal;
