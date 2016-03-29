function rvu(){
    var view = document.getElementById('rvu_scene').value
    var query = 'skp:rvu@{"scene":"'+view+'"}';
    window.location.href = query;
}

function load_rvu_views(){
    var selectbox = document.getElementById("rvu_scene");
    for(i=selectbox.options.length-1;i>=0;i--)
    {
        selectbox.remove(i);
    }
    window.location.href = 'skp:load_views@message';
}


function calc_DF(){
    var query = 'skp:calc_DF@{""}';
    window.location.href = query;
}

function calc_actual_illuminance(){
    var sky = document.getElementById('actual_illuminance_sky').value;
    var query = 'skp:calc_actual_illuminance@{"sky":"'+sky+'"}';
    window.location.href = query;
}

function calc_DA(){
    var threshold = document.getElementById('da_threshold').value;
    var bins = document.getElementById('da_bins').value;
    var method = document.getElementById('da_method').value;
    var early = document.getElementById('da_early').value;
    var late = document.getElementById('da_late').value;

    var query = 'skp:calc_DA@{"threshold":'+threshold+',"bins":'+bins+',"method":"'+method+'","early":'+early+',"late":'+late+'}';

    window.location.href = query;

}

function calc_UDI(){
    var lower_threshold = document.getElementById('udi_lower_threshold').value;
    var upper_threshold = document.getElementById('udi_upper_threshold').value;
    var bins = document.getElementById('udi_bins').value;
    var method = document.getElementById('udi_method').value;
    var early = document.getElementById('udi_early').value;
    var late = document.getElementById('udi_late').value;

    if(parseFloat(lower_threshold) > parseFloat(upper_threshold)){
        alert("Lower threshold is larger than upper threshold.");
        return;
    }

    var query = 'skp:calc_UDI@{"upper_threshold":'+upper_threshold+',"lower_threshold":'+lower_threshold+',"bins":'+bins+',"method":"'+method+'","early":'+early+',"late":'+late+'}';
    window.location.href = query;
}

load_rvu_views();
