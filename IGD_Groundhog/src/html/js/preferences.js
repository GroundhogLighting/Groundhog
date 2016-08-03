//preferences.js

preferencesModule={};

preferencesModule.set_element_value = function(elementID, value){
    var element = $("#"+elementID);
    if(element.is(":checkbox")) {
        if(value == "true" || value == true){
            element.prop("checked",true);
            element.val(true);
        }else if(value=="false" || value==false){
            element.prop("checked",false);
            element.val(false);
        }else{
            alert("Incorrect input type for setting preferences");
            return false;
        }
    }else{
        element.val(value);
    }

};