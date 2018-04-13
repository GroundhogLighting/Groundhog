var isDev = require('./is-dev');
var skpVersion = require('./skp-version');

module.exports = {
    call_action : function(actionName, args){
        if(isDev){
            alert("calling "+actionName+'(\"'+args+'\");');
        }else{
            if(skpVersion === 'html_dialog'){
                eval('sketchup.'+actionName+'(\"'+args+'\");');
            }else if(skpVersion === 'web_dialog'){
                window.location = 'skp:'+actionName+'@'+args;
            }else{
                alert("Unkown SketchUp UI version '"+skpVersion+"'");
            }
        }
    }
}