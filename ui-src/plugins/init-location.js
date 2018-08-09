
if(require("~/plugins/is-dev")){
      
    global.project_location = {
        "country" : "Chile",
        "city": "Santiago",
        "latitude" : -33,
        "longitude" : -73,
        "timezone" : -4,
        "albedo" : 0.2
    }
    global.has_weather_file = [true];
}else{  
    global.project_location = {
        "country" : "",
        "city": "",
        "latitude" : "",
        "longitude" : "",
        "timezone" : "",
        "albedo" : 0.2
    };
    global.has_weather_file = [false];// Needs to be an array, so it is used by reference
}
  