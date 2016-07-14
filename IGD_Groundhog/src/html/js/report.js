var reportModule = {};

reportModule.update_objective_summary = function(){    
    var div = $("#objective_summary");
    div.html("");
    var objs = Object.keys(objectives);

    for(var i=0; i<objs.length; i++){
        /* FIRST, its own div */
        var newDiv = $("<div></div>");
        var name = $("<h4>"+objs[i]+"</h4>");
        newDiv.append(name);
        var text = objectiveModule.get_human_description(objectives[objs[i]]);
        var description = $("<p>"+text+"</p>");
        newDiv.append(description);
        div.append(newDiv);
    }
}

reportModule.update_compliance_summary = function(){
    var table = $("#compliance_summary");
    table.html("");
    var objs = Object.keys(objectives);

    /* FIRST, ADD HEADER */
    var header = $("<tr></tr>");
    //empty column, where workplanes names will be written
    header.append($("<td></td>"));        
    for(var i=0; i<objs.length; i++){
        var name = $("<td>"+objs[i]+"</td>");
        name.on("click",function(){                    
            window.location.href = 'skp:remark@'+$(this).text();
        }); 
        header.append(name);
    }
    table.append(header);

    for (var wp_name in results) {
        if (results.hasOwnProperty(wp_name)) {
            var row = $("<tr></tr>");                                          
            row.append($("<td>"+wp_name+"</td>"));
                        
            for(var i=0; i<objs.length; i++){
                var obj_name = objs[i];
                     
                var col = $("<td></td>")
                if(results[wp_name].hasOwnProperty(obj_name)){
                    var s = results[wp_name][obj_name]*100;
                    col.text(Math.round(s)+"%");
                    if(objectives[obj_name]["goal"] < s){
                        col.addClass("success");
                    }else{
                        col.addClass("not-success");
                    }
                }
                row.append(col);
            }
            table.append(row);
        }
    }
}
