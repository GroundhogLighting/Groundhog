

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

function calc_annual_illuminance(){
    var gr_rho = document.getElementById('da_rho').value;
    var bins = document.getElementById('da_bins').value;
    var method = document.getElementById('da_method').value;

    var query = 'skp:calc_annual_illuminance@{"ground_rho":"'+gr_rho+'","bins":'+bins+',"method":"'+method+'"}';

    window.location.href = query;

}
