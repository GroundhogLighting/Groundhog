var isDev = require("~/plugins/is-dev");

global.luminaires = []

if(isDev){
    global.luminaires.push({name: "Luminaire 1", manufacturer: "Some manufacturer", lamp: "The Lamp"});
}