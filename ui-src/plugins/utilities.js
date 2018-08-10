

global.unique = function(arr){
    const onlyUnique = function(value, index, self) { 
        return self.indexOf(value) === index;
    }
    return arr.filter(onlyUnique);
}


global.updateByField = function(arr,fieldName,fieldValue,value){
    var index = arr.findIndex(function(e){
        return e[fieldName] == fieldValue;
    })

    if(index > -1){
        // If item is there
        //arr.splice(index,1);
        arr[index] = Object.assign({},value);
    }else{
        arr.push(value)
    }
};


global.deleteByField = function(arr,fieldName,fieldValue){
    var index = arr.findIndex(function(e){
        return e[fieldName] == fieldValue;
    })

    if(index > -1){
        // If item is there
        arr.splice(index,1);        
    }
};

global.updateByFields = function(arr,fieldNames,fieldValues,value){
    var index = arr.findIndex(function(e){
        for(var i = 0; i< fieldNames.length; i++){
            const fieldName = fieldNames[i]
            const fieldValue = fieldValues[i];
            if(e[fieldName] !== fieldValue){
                return false;
            }
        }
        return true
    })

    if(index > -1){
        // If item is there
        //arr.splice(index,1);
        arr[index] = Object.assign({},value);
    }else{
        arr.push(value)
    }
};



global.updateByName = function(arr,value){
    return updateByField(arr,"name",value.name,value);
};


global.deleteByName = function(arr,name){
    return deleteByField(arr,"name",name);
};

global.trimByName = function(template,arr){    
    arr.forEach(function(e){                
        if(!template.includes(e.name)){            
            deleteByName(arr,e.name);
        }
    });
}
