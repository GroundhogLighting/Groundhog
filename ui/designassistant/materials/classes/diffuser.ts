
import { MaterialType, Material } from '../definitions';
import { Response } from '../../../common/core';

let Diffuser: MaterialType = {
    name : "Diffuser",   
    inputs: [
        {name: "Red", value: 0.7, min: 0, max:1}, 
        {name: "Green", value: 0.7, min: 0, max:1}, 
        {name: "Blue", value: 0.7, min: 0, max:1},
        {name: "Diffuse Reflectance", value: 0.2, min: 0.01, max: 1},
    ],
    rad : "void trans %MAT_NAME% 0 0 7 %red% %green% %blue% 0 0 %total_transmittance% 0",
    color_property : "Diffuse Transmittance",

    process: function(inputs: any) : any {        
        let rd = inputs["Diffuse Reflectance"];        
        let td = 0.265*inputs["Red"] + 0.67*inputs["Green"] + 0.065*inputs["Blue"];
        if(td + rd > 1){
            alert("Reflectance and Transmittance are too high. Please lower at least one of them.")
            return;
        }        
        let a6 = td / (td + rd);                
        inputs["Red"] = inputs["Red"]/a6;
        inputs["Green"] = inputs["Green"]/a6;
        inputs["Blue"] = inputs["Blue"]/a6;
        inputs["Total Transmittance"] = a6;

        inputs["alpha"] =  Math.sqrt(1-td);
        if(inputs["alpha"] > 0.95){inputs["alpha"] = 0.95};
        return inputs
    },

    parse : function(material: Material): void {
        let rad = material["rad"];
        let data = rad.split(" ");    

        let c_red = parseFloat(data[6]);
        let c_green = parseFloat(data[7]);
        let c_blue = parseFloat(data[8]);
        let a6 = parseFloat(data[11]);

        let red = c_red * a6;
        let green = c_green * a6;
        let blue = c_blue * a6;
        
        let rdx = c_red - red;
        let rdy = c_green - green;
        let rdz = c_blue - blue;
        
        let rd = 0.265 * rdx + 0.67 * rdy + 0.065 * rdz;

        $("#red").val(red);
        $("#green").val(green);
        $("#blue").val(blue);  
        $("#material_diffuse_transmittance").val(rd);
    } 

}

export = Diffuser;
