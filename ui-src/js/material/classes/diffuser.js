"use strict";
var Diffuser = {
    name: "Diffuser",
    inputs: [
        { name: "Red", value: 0.7, min: 0, max: 1 },
        { name: "Green", value: 0.7, min: 0, max: 1 },
        { name: "Blue", value: 0.7, min: 0, max: 1 },
        { name: "Diffuse Reflectance", value: 0.2, min: 0.01, max: 1 },
    ],
    rad: "void trans %MAT_NAME% 0 0 7 %red% %green% %blue% 0 0 %total_transmittance% 0",
    color_property: "Diffuse Transmittance",
    process: function (inputs) {
        var rd = inputs["Diffuse Reflectance"];
        var td = 0.265 * inputs["Red"] + 0.67 * inputs["Green"] + 0.065 * inputs["Blue"];
        if (td + rd > 1) {
            alert("Reflectance and Transmittance are too high. Please lower at least one of them.");
            return;
        }
        var a6 = td / (td + rd);
        inputs["Red"] = inputs["Red"] / a6;
        inputs["Green"] = inputs["Green"] / a6;
        inputs["Blue"] = inputs["Blue"] / a6;
        inputs["Total Transmittance"] = a6;
        inputs["alpha"] = Math.sqrt(1 - td);
        if (inputs["alpha"] > 0.95) {
            inputs["alpha"] = 0.95;
        }
        ;
        return inputs;
    },
    parse: function (material) {
        var rad = material["rad"];
        var data = rad.split(" ");
        var c_red = parseFloat(data[6]);
        var c_green = parseFloat(data[7]);
        var c_blue = parseFloat(data[8]);
        var a6 = parseFloat(data[11]);
        var red = c_red * a6;
        var green = c_green * a6;
        var blue = c_blue * a6;
        var rdx = c_red - red;
        var rdy = c_green - green;
        var rdz = c_blue - blue;
        var rd = 0.265 * rdx + 0.67 * rdy + 0.065 * rdz;
        $("#red").val(red);
        $("#green").val(green);
        $("#blue").val(blue);
        $("#material_diffuse_transmittance").val(rd);
    }
};
module.exports = Diffuser;
//# sourceMappingURL=diffuser.js.map