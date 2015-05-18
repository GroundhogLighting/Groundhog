
function calcLight(){
	var name=document.getElementById("light_name").value;
	
	var red=document.getElementById("light_red").value;
	var green=document.getElementById("light_green").value;
	var blue=document.getElementById("light_blue").value;

	if(name=="" || red=="" || green=="" || blue=="" ){
		alert("Please fill all the required inputs");
		return;
	}	
	if(red<0 || green<0 || blue<0){
		alert("Red, Green and Blue components need to be greater than or equal to 0");
		return;
	}

	var mod_type="void light"
	var argument="0 0 3 "+red+" "+green+" "+blue
	
	render_red=red;
	render_green=green;
	render_blue=blue;
	alpha=0
	
	var query = 'skp:get_material_JSON@{"alpha":'+alpha+',"name":"'+name+'","red":'+render_red+',"green":'+render_green+', "blue":'+render_blue+', "mod_type":"'+mod_type+'", "argument":"'+argument+'"}';
	window.location.href = query;
}

function calcGlow(){
	var name=document.getElementById("glow_name").value;
	var red=document.getElementById("glow_red").value;
	var green=document.getElementById("glow_green").value;
	var blue=document.getElementById("glow_blue").value;
	var maxrad=document.getElementById("glow_maxrad").value;
	
	if(name=="" || red=="" || green=="" || blue=="" || maxrad==""){
		alert("Please fill all the required inputs");
		return;
	}	
	if(red<0 || green<0 || blue<0){
		alert("Red, Green and Blue components need to be greater than or equal to 0");
		return;
	}

	var mod_type="void glow"
	var argument="0 0 4 "+red+" "+green+" "+blue+" "+maxrad
	
	render_red=red;
	render_green=green;
	render_blue=blue;
	alpha=0
	
	var query = 'skp:get_material_JSON@{"alpha":'+alpha+',"name":"'+name+'","red":'+render_red+',"green":'+render_green+', "blue":'+render_blue+', "mod_type":"'+mod_type+'", "argument":"'+argument+'"}';
	window.location.href = query;
}

function calcSpotLight(){
	var name=document.getElementById("spotlight_name").value;
	var red=document.getElementById("spotlight_red").value;
	var green=document.getElementById("spotlight_green").value;
	var blue=document.getElementById("spotlight_blue").value;
	var angle=document.getElementById("spotlight_angle").value;
	var x=document.getElementById("spotlight_x").value;
	var y=document.getElementById("spotlight_y").value;
	var z=document.getElementById("spotlight_z").value;	
	
	if(name=="" || red=="" || green=="" || blue=="" || angle=="" || x=="" || y=="" || z==""){
		alert("Please fill all the required inputs");
		return;
	}	
	if(red<0 || green<0 || blue<0){
		alert("Red, Green and Blue components need to be greater than or equal to 0");
		return;
	}
	if(x*x+y*y+z*z<0){
		alert("The direction you input has a length of zero. Please insert a valid direction.");
		return;
	}	
	if(angle<0 || angle>360){
		alert("The angle must be a number between 0 and 360.");
		return;
	}	
				
	var mod_type="void spotlight"
	var argument="0 0 7 "+red+" "+green+" "+blue+" "+angle+" "+x+" "+y+" "+z
	
	render_red=red;
	render_green=green;
	render_blue=blue;
	alpha=0
	
	var query = 'skp:get_material_JSON@{"alpha":'+alpha+',"name":"'+name+'","red":'+render_red+',"green":'+render_green+', "blue":'+render_blue+', "mod_type":"'+mod_type+'", "argument":"'+argument+'"}';
	window.location.href = query;
}		

function calcPlastic(){
	var name=document.getElementById("plastic_name").value;
	var red=document.getElementById("plastic_red").value;
	var green=document.getElementById("plastic_green").value;
	var blue=document.getElementById("plastic_blue").value;
	var specularity=document.getElementById("plastic_specularity").value;
	var roughness=document.getElementById("plastic_roughness").value;
		
	if(name=="" || red=="" || green=="" || blue=="" || specularity=="" || roughness==""){
		alert("Please fill all the required inputs");
		return;
	}	
	if(red<0 || green<0 || blue<0 || specularity <0 || roughness <0){
		alert("Red, Green and Blue components and specularity and roughness need to be between 0 and 1.");
		return;
	}	
	if(red>1 || green>1 || blue>1 || specularity >1 || roughness >1){
		alert("Red, Green and Blue components and specularity and roughness need to be between 0 and 1.");
		return;
	}		
	
	var mod_type="void plastic"
	var argument="0 0 5 "+red+" "+green+" "+blue+" "+specularity+" "+roughness

	
	render_red=red;
	render_green=green;
	render_blue=blue;
	alpha=0
	
	var query = 'skp:get_material_JSON@{"alpha":'+alpha+',"name":"'+name+'","red":'+render_red+',"green":'+render_green+', "blue":'+render_blue+', "mod_type":"'+mod_type+'", "argument":"'+argument+'"}';
	window.location.href = query;
}		

function calcMetal(){
	var name=document.getElementById("metal_name").value;
	var red=document.getElementById("metal_red").value;
	var green=document.getElementById("metal_green").value;
	var blue=document.getElementById("metal_blue").value;	
	var specularity=document.getElementById("metal_specularity").value;
	var roughness=document.getElementById("metal_roughness").value;
			
	if(name=="" || red=="" || green=="" || blue=="" || specularity=="" || roughness==""){
		alert("Please fill all the required inputs");
		return;
	}	
	if(red<0 || green<0 || blue<0 || specularity <0 || roughness <0){
		alert("Red, Green and Blue components and specularity and roughness need to be between 0 and 1.");
		return;
	}	
	if(red>1 || green>1 || blue>1 || specularity >1 || roughness >1){
		alert("Red, Green and Blue components and specularity and roughness need to be between 0 and 1.");
		return;
	}		
				
	var mod_type="void metal"
	var argument="0 0 5 "+red+" "+green+" "+blue+" "+specularity+" "+roughness
	
	render_red=red;
	render_green=green;
	render_blue=blue;
	alpha=0
	
	var query = 'skp:get_material_JSON@{"alpha":'+alpha+',"name":"'+name+'","red":'+render_red+',"green":'+render_green+', "blue":'+render_blue+', "mod_type":"'+mod_type+'", "argument":"'+argument+'"}';
	window.location.href = query;
}

function calcTrans(){
	var name=document.getElementById("trans_name").value;
	var red=document.getElementById("trans_red").value;
	var green=document.getElementById("trans_green").value;
	var blue=document.getElementById("trans_blue").value;
	var specularity=document.getElementById("trans_specularity").value;
	var roughness=document.getElementById("trans_roughness").value;
	var trans=document.getElementById("trans_trans").value;
	var tspec=document.getElementById("trans_tspec").value;

	if(name=="" || red=="" || green=="" || blue=="" || specularity=="" || roughness=="" || trans=="" || tspec==""){
		alert("Please fill all the required inputs");
		return;
	}	
	if(red<0 || green<0 || blue<0 || specularity <0 || roughness <0 || trans<0 || tspec< 0){
		alert("Red, Green and Blue components and specularity and roughness and Spec. trans. need to be between 0 and 1.");
		return;
	}	
	if(red>1 || green>1 || blue>1 || specularity >1 || roughness >1 || trans > 1 || tspec> 1){
		alert("Red, Green and Blue components and specularity and roughness and Spec. trans. need to be between 0 and 1.");
		return;
	}	
				
	var mod_type="void trans"
	var argument="0 0 7 "+red+" "+green+" "+blue+" "+specularity+" "+roughness+" "+trans+" "+tspec
	
	render_red=red;
	render_green=green;
	render_blue=blue;
	alpha=parseFloat(trans)
	
	var query = 'skp:get_material_JSON@{"alpha":'+alpha+',"name":"'+name+'","red":'+render_red+',"green":'+render_green+', "blue":'+render_blue+', "mod_type":"'+mod_type+'", "argument":"'+argument+'"}';
	window.location.href = query;
}	

function calcDielectric(){
	var name=document.getElementById("dielectric_name").value;
	var red=document.getElementById("dielectric_red").value;
	var green=document.getElementById("dielectric_green").value;
	var blue=document.getElementById("dielectric_blue").value;
	var refraction=document.getElementById("dielectric_refraction").value;
	var hartmann=document.getElementById("dielectric_hartmann").value;

	if(name=="" || red=="" || green=="" || blue=="" || refraction=="" || hartmann==""){
		alert("Please fill all the required inputs");
		return;
	}	
	if(red<0 || green<0 || blue<0){
		alert("Red, Green and Blue components  need to be between 0 and 1.");
		return;
	}	
	if(red>1 || green>1 || blue>1){
		alert("Red, Green and Blue components and specularity and roughness and Spec. trans. need to be between 0 and 1.");
		return;
	}	
	if(refraction<1 || refraction>2){
		alert("Refractive index must be between 1 and 2");
		return;
	}
	if(hartmann<-2 || hartmann>3){
		alert("Hartmann constant must be between -2 and 3");
		return;
	}
				
	var mod_type="void dielectric"
	var argument="0 0 5 "+red+" "+green+" "+blue+" "+refraction+" "+hartmann
	
	render_red=red;
	render_green=green;
	render_blue=blue;
	alpha=0.5
	
	var query = 'skp:get_material_JSON@{"alpha":'+alpha+',"name":"'+name+'","red":'+render_red+',"green":'+render_green+', "blue":'+render_blue+', "mod_type":"'+mod_type+'", "argument":"'+argument+'"}';
	window.location.href = query;
}	

function calcGlass(){
	var name=document.getElementById("glass_name").value;
	var red=document.getElementById("glass_red").value;
	var green=document.getElementById("glass_green").value;
	var blue=document.getElementById("glass_blue").value;

	if(name=="" || red=="" || green=="" || blue=="" ){
		alert("Please fill all the required inputs");
		return;
	}	
	if(red<0 || green<0 || blue<0 ){
		alert("Red, Green and Blue components need to be between 0 and 1.");
		return;
	}	
	if(red>1 || green>1 || blue>1 ){
		alert("Red, Green and Blue components need to be between 0 and 1.");
		return;
	}	
			

				
	var mod_type="void glass"
	var argument="0 0 3 "+red+" "+green+" "+blue
	
	render_red=red;
	render_green=green;
	render_blue=blue;
	alpha=1.0-(parseFloat(red)*0.265+parseFloat(green)*0.67+parseFloat(blue)*0.065)
	
	var query = 'skp:get_material_JSON@{"alpha":'+alpha+',"name":"'+name+'","red":'+render_red+',"green":'+render_green+', "blue":'+render_blue+', "mod_type":"'+mod_type+'", "argument":"'+argument+'"}';
	window.location.href = query;
}	

						