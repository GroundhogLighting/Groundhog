function rvu(){

    var query = 'skp:rvu@{""}';
    window.location.href = query;
}

function calc_DF(){
    var query = 'skp:calc_DF@{""}';
    window.location.href = query;
}

function calc_actual_illuminance(){
    var sky = document.getElementById('actual_illuminance_sky').value;
    var gr_rho = document.getElementById('actual_illuminance_rho').value;
    var query = 'skp:calc_actual_illuminance@{"sky":"'+sky+'","ground_rho":"'+gr_rho+'"}';
    window.location.href = query;
}

function calc_DA(){
    var gr_rho = document.getElementById('da_rho').value;
    var threshold = document.getElementById('da_threshold').value;
    var bins = document.getElementById('da_bins').value;
    var method = document.getElementById('da_method').value;

    var query = 'skp:calc_DA@{"ground_rho":"'+gr_rho+'","threshold":'+threshold+',"bins":'+bins+',"method":"'+method+'"}';
    window.location.href = query;

}

function calc_UDI(){
    var gr_rho = document.getElementById('udi_rho').value;
    var lower_threshold = document.getElementById('udi_lower_threshold').value;
    var upper_threshold = document.getElementById('udi_upper_threshold').value;
    var bins = document.getElementById('udi_bins').value;
    var method = document.getElementById('udi_method').value;

    if(parseFloat(lower_threshold) > parseFloat(upper_threshold)){
        alert("Lower threshold is larger than upper threshold.");
        return;
    }

    var query = 'skp:calc_UDI@{"ground_rho":"'+gr_rho+'","upper_threshold":'+upper_threshold+',"lower_threshold":'+lower_threshold+',"bins":'+bins+',"method":"'+method+'"}';
    window.location.href = query;

}
