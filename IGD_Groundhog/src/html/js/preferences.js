function set_radiance_preferences(){
	var rad_path=document.getElementById("rad_path").value;
	var weather_path=document.getElementById('weather_path_input').innerHTML
	var rvu=document.getElementById("rvu").value;
	var rcontrib=document.getElementById("rcontrib").value;
	var rtrace=document.getElementById("rtrace").value;


	var extension = weather_path.split('.').pop();
	if(weather_path != "c:/" && (extension !="epw" && extension!="wea")){
		alert('You did not choose a valid weather file (i.e. EPW or WEA). Preferences will be saved, but you will be bothered when trying to perform annual simulations.');
	}

	var query = 'skp:set_radiance_preferences@{"RADIANCE_PATH":"'+rad_path+'","WEATHER_PATH":"'+weather_path+'","RVU":"'+rvu+'","RCONTRIB":"'+rcontrib+'","RTRACE":"'+rtrace+'"}';

	window.location.href = query;
}

function set_general_preferences(){
	var sensor_spacing=parseFloat(document.getElementById("sensor_spacing").value);
	if(isNaN(sensor_spacing)){
		alert("Please fill all the required inputs with valid arguments");
		return;
	}
	if(sensor_spacing<=0){
		alert("Sensor spacing needs to be a number greater than 0.");
		return;
	}
	var query = 'skp:set_general_preferences@{"SENSOR_SPACING":'+sensor_spacing+'}';

	window.location.href = query;
}

function set_weather_path(){
	window.location.href = 'skp:set_weather_path@msg';
}

//document.onload = function(){
	window.location.href = 'skp:onLoad@message';
//}
