//luminaires.js

var luminaireModule = {};

luminaireModule.useLuminaire = function(name){
    alert("Using "+name);
};


luminaireModule.deleteLuminaire = function(name){
    alert("Deleting "+name);
};

luminaireModule.update_list = function (filter) {
    filter = filter.toLowerCase();
    var list = $("#luminaire_list");
    list.html("");
    var html = "<tr><td>Name</td><td>Brand</td><td>Power</td><td></td></tr>"
    for (var luminaire in luminaires) {
        if (luminaires.hasOwnProperty(luminaire)) {
            var data = luminaires[luminaire];
            var brand = data["brand"];
            var power = data["power"];
            if (luminaire.toLowerCase().indexOf(filter) >= 0 || brand.toLowerCase().indexOf(filter) >= 0) {                                
                html = html + "<tr><td class='luminaire-name' name=\"" + luminaire + "\">" + luminaire + "</td><td>" + brand + "</td><td>"+power+" W</td><td class='icons'><span name=\"" + luminaire + "\" class='ui-icon ui-icon-trash del-luminaire'></span></td></tr>" 
                //<span class='ui-icon ui-icon-pencil'></span>
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
