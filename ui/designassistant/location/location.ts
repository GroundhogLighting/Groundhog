import Utilities = require('../Utilities');
import { Response } from '../../common/core';

//import * as $ from 'jquery'

export = class LocationModule {

    constructor(debug: boolean){
        $("#change_weather_button").on("click",function(){
            Utilities.sendAction("set_weather_path","msg")
        })
        $("#get_epw_weather").on("click",function(){
            Utilities.sendAction("follow_link","http://www.energyplus.net/weather");
        })
    }

    setWeatherData = (weather: any) => {
        $("#weather_city").html(weather["city"]);
        $("#weather_state").html(weather["state"]);
        $("#weather_country").html(weather["country"]);
        $("#weather_latitude").html(weather["latitude"]);
        $("#weather_longitude").html(weather["longitude"]);
        $("#weather_timezone").html("GMT "+weather["timezone"]);
    }

}