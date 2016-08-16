//luminaires.js

var luminaireModule = {};

luminaireModule.useLuminaire = function(name){
    var msg = luminaires[name];
    msg["name"] = name;
    var cmd = "skp:use_luminaire@"+JSON.stringify(msg);
    window.location.href = cmd
};


luminaireModule.deleteLuminaire = function(name){
    alert("Deleting "+name);
};

luminaireModule.update_list = function (filter) {
    var list = $("#luminaire_list");
    list.html("");
    if(Object.keys(luminaires).length == 0){
        $("<div class='center'><h4>There are no luminaires in your model...</h4></div>").appendTo(list);
        return;
    }
    filter = filter.toLowerCase();
    
    var html = "<tr><td>Luminaire</td><td>Manufacturer</td><td>Lamp</td></tr>"
    for (var luminaire in luminaires) {
        if (luminaires.hasOwnProperty(luminaire)) {
            var data = luminaires[luminaire];
            var desc = data["luminaire"];
            var manufacturer = data["manufacturer"];
            var lamp = data["lamp"];
            if (    luminaire.toLowerCase().indexOf(filter) >= 0 || 
                    manufacturer.toLowerCase().indexOf(filter) >= 0 ||
                    lamp.toLowerCase().indexOf(filter) >= 0 
                ) {                                
                    html = html + "<tr><td class='luminaire-name' name=\"" + luminaire + "\">" + luminaire + "</td><td>" + manufacturer + "</td><td>"+lamp+"</td></tr>" 
                    //<td class='icons'><span name=\"" + luminaire + "\" class='ui-icon ui-icon-trash del-luminaire'></span><span class='ui-icon ui-icon-pencil'></span></td>
            }
        }
    }
    list.html(html);

    $("td.luminaire-name").on("click", function () {
        var name = $(this).attr("name");
        luminaireModule.useLuminaire(name);
    });


    $("span.del-luminaire").on("click", function () {
        var name = $(this).attr("name");
        luminaireModule.deleteLuminaire(name);
    });
}


$("#filter_luminaires").keyup(function () {
    luminaireModule.update_list(this.value);
});
