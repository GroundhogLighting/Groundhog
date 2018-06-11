
if(require("~/plugins/is-dev")){
      
    project_location = {
        "country" : "Chile",
        "city": "Santiago",
        "latitude" : -33,
        "longitude" : -73,
        "timezone" : -4,
        "albedo" : 0.2
    }
    has_weather_file = true;
}else{  
    project_location = {
        "country" : "",
        "city": "",
        "latitude" : "",
        "longitude" : "",
        "timezone" : "",
        "albedo" : 0.2
    };
    has_weather_file = false;
}
  