var isDev = require('./is-dev');
var skpVersion = require('./skp-version');

export default {
    call_action : function(actionName, args){
        // Check type
        const type = typeof args;
        if(type === 'object'){
            args = JSON.stringify(args);
        }else if(type !== 'string' && type !== 'number'){
            const msg = 'passed to SketchUp helper must be of type String, Number or Object'
            alert(msg);
            throw msg;
        }

        if(isDev){
            console.log("SKP >>>>> calling "+actionName+'(\''+args+'\');');
        }else{
            if(skpVersion === 'html_dialog'){
                eval('sketchup.'+actionName+'(\''+args+'\');');
            }else if(skpVersion === 'web_dialog'){
                window.location = 'skp:'+actionName+'@'+args;
            }else{
                alert("Unkown SketchUp UI version '"+skpVersion+"'");
            }
        }
    }
}