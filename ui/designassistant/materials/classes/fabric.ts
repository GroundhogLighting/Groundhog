
import { MaterialType, Material } from '../definitions';
import { Response } from '../../../common/core';

let Diffuser: MaterialType = {
    name : "Fabric",   
    inputs: [
        {name: "Red", value: 0.04, min: 0, max:1}, 
        {name: "Green", value: 0.04, min: 0, max:1}, 
        {name: "Blue", value: 0.04, min: 0, max:1},
        {name: "Direct Transmittance", value: 0.12, min: 0.01, max: 0.99},
        {name: "Diffuse Reflectance", value: 0.05, min: 0.01, max: 1}
    ],
    rad : "void trans %base_material_name% 0 0 7 %red% %green% %blue% 0 0 %total_transmittance% 0  void mixfunc %MAT_NAME% 4 void %base_material_name% direct_transmittance %funcfile% 0 0",
    support_files : [{name : "funcfile", content : "direct_transmittance = %direct_transmittance%;"}],
    color_property : "Diffuse Transmittance",

    process: function(inputs: any) : any {    
        let ts =  inputs["Direct Transmittance"];        
        let td = 0.265*inputs["Red"] + 0.67*inputs["Green"] + 0.065*inputs["Blue"];
        let rd = inputs["Diffuse Reflectance"];
        if(ts + td + rd > 1){
            alert("Reflectance and Transmittance are too high. Please lower at least one of them.")
            return;
        } 
        // Calculate it, but transform into the material... that is, increase it        
        let a6 = td / (td + rd);                
        inputs["Red"] = inputs["Red"]/(a6*(1-ts));
        inputs["Green"] = inputs["Green"]/(a6*(1-ts));
        inputs["Blue"] = inputs["Blue"]/(a6*(1-ts));
        inputs["Total Transmittance"] = a6;
        inputs["base_material_name"] = inputs["name"].toLowerCase().replace(/\s/g, "_")+"_base_material";
        
        inputs["alpha"] =  Math.sqrt(1-td-ts);
        if(inputs["alpha"] > 0.95){inputs["alpha"] = 0.95};
        return inputs
    },

    parse : function(material: Material): void {
        
        let support_files = material["support_files"];
        let funcfile = support_files[0]["content"].split(" = ");
        let transparency = parseFloat(funcfile[1].replace(new RegExp(";",'g'),""));
        
        let rad = material["rad"];
        let data = rad.split(" ");    

        let c_red = parseFloat(data[6]) ;
        let c_green = parseFloat(data[7]) ;
        let c_blue = parseFloat(data[8]) ;
        let a6 = parseFloat(data[11]);

        let red = c_red * a6 * (1-transparency);
        let green = c_green * a6 * (1-transparency);
        let blue = c_blue * a6 * (1-transparency);
        
        let rdx = c_red - red;
        let rdy = c_green - green;
        let rdz = c_blue - blue;
        
        let rd = 0.265 * rdx + 0.67 * rdy + 0.065 * rdz;


        $("#red").val(red);
        $("#green").val(green);
        $("#blue").val(blue);  
        $("#material_diffuse_transmittance").val(rd);
        $("#material_direct_transmittance").val(transparency);
    } 

}

export = Diffuser;
