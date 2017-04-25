"use strict";
var Glass = {
    name: "Glass",
    inputs: [
        { name: "Red", value: 0.7, min: 0, max: 1 },
        { name: "Green", value: 0.7, min: 0, max: 1 },
        { name: "Blue", value: 0.7, min: 0, max: 1 }
    ],
    rad: "void glass %MAT_NAME% 0 0 3 %red% %green% %blue%",
    color_property: "Transmittance",
    process: function (inputs) {
        inputs["Red"] = inputs["Red"] * 1.0895;
        inputs["Green"] = inputs["Green"] * 1.0895;
        inputs["Blue"] = inputs["Blue"] * 1.0895;
        inputs["alpha"] = Math.sqrt(1 - (0.265 * inputs["Red"] + 0.67 * inputs["Green"] + 0.065 * inputs["Blue"]));
        if (inputs["alpha"] > 0.95) {
            inputs["alpha"] = 0.95;
        }
        ;
        return inputs;
    },
    parse: function (material) {
        var rad = material["rad"];
        var data = rad.split(" ");
        $("#red").val(parseFloat(data[6]) / 1.0895);
        $("#green").val(parseFloat(data[7]) / 1.0895);
        $("#blue").val(parseFloat(data[8]) / 1.0895);
    }
};
module.exports = Glass;
//# sourceMappingURL=glass.js.map