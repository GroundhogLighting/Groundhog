var isDev = require("~/plugins/is-dev");

global.photosensors = []
global.selected_photosensor = {};

if(isDev){
    global.photosensors.push({ name: "Photosensor 1", px: 0, py: 0, pz: 0.8, dx: 0, dy: 0, dz: 1});
    global.photosensors.push({ name: "Photosensor 2", px: 1, py: 1, pz: 0.8, dx: 0, dy: 0, dz: 1});
}