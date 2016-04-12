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
    var query = 'skp:calc_DA@{""}';
    window.location.href = query;

}

function calc_UDI(){

    var query = 'skp:calc_UDI@{""}';
    window.location.href = query;
}

load_rvu_views();
