function set_radiance_preferences(){
	var rad_path=document.getElementById("rad_path").value;
	var weather_path=document.getElementById("weather_path").value;
	var rvu=document.getElementById("rvu").value;
	var rcontrib=document.getElementById("rcontrib").value;
	var rtrace=document.getElementById("rtrace").value;
	

	
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
		
window.location.href = 'skp:onLoad@message';