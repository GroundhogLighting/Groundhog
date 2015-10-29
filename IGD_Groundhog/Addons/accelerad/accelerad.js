

function save_config(){
    rtrace=document.getElementById('rtrace').value;
    var query = 'skp:save_config@{"rtrace":"'+rtrace+'"}';
    window.location.href = query;
}

window.location.href = 'skp:onLoad@message';
