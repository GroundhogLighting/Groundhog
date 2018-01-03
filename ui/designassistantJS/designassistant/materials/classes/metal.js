"use strict";
var Metal = {
    name: "Metal",
    inputs: [
        { name: "Specularity", value: 0, max: 1, min: 0 },
        { name: "Roughness", value: 0, max: 1, min: 0 },
        { name: "Red", value: 0.6, max: 1, min: 0 },
        { name: "Green", value: 0.6, max: 1, min: 0 },
        { name: "Blue", value: 0.6, max: 1, min: 0 },
    ],
    rad: "void plastic %MAT_NAME% 0 0 5 %red% %green% %blue% %specularity% %roughness%",
    color_property: "Reflectance",
    process: function (inputs) {
        inputs["alpha"] = 1;
        return inputs;
    },
    parse: function (material) {
        var rad = material["rad"];
        var data = rad.split(" ");
        $("#red").val(data[6]);
        $("#reen").val(data[7]);
        $("#blue").val(data[8]);
        $("#material_specularity").val(data[9]);
        $("#material_roughness").val(data[10]);
    }
};
module.exports = Metal;
//# sourceMappingURL=metal.js.map