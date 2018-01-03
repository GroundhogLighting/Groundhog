"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function LuminairesModule(debug) {
        var _this = this;
        this.useLuminaire = function (name) {
            var msg = _this.luminaires[name];
            msg["name"] = name;
            Utilities.sendAction("use_luminaire", JSON.stringify(msg));
        };
        this.deleteLuminaire = function (name) {
            var msg = _this.luminaires[name];
            Utilities.sendAction("delete_luminaire", JSON.stringify(msg));
        };
        this.updateList = function (filter) {
            var list = $("#luminaire_list");
            list.html("");
            if (Object.keys(_this.luminaires).length == 0) {
                $("<div class='center'><h4>There are no luminaires in your model...</h4></div>").appendTo(list);
                return;
            }
            filter = filter.toLowerCase();
            var html = "<tr><td>Luminaire</td><td>Manufacturer</td><td>Lamp</td></tr>";
            for (var luminaire_name in _this.luminaires) {
                var luminaire = _this.luminaires[luminaire_name];
                var manufacturer = luminaire.manufacturer;
                var lamp = luminaire.lamp;
                if (luminaire.name.toLowerCase().indexOf(filter) >= 0 ||
                    manufacturer.toLowerCase().indexOf(filter) >= 0 ||
                    lamp.toLowerCase().indexOf(filter) >= 0) {
                    html = html + "<tr>" +
                        "<td class='luminaire-name' name=\"" + luminaire.name + "\">" + luminaire.name + "</td>" +
                        "<td>" + manufacturer + "</td>" +
                        "<td>" + lamp + "</td>" +
                        "<td name='" + luminaire_name + "'>"
                        + "<i name='" + luminaire_name + "' class='material-icons del-luminaire'>delete</i>"
                        + "</td>";
                    "</tr>";
                }
            }
            list.html(html);
            var useLuminaire = _this.useLuminaire;
            $("td.luminaire-name").on("click", function () {
                var name = $(this).attr("name");
                useLuminaire(name);
            });
            var deleteLuminaire = _this.deleteLuminaire;
            $("i.del-luminaire").on("click", function () {
                var name = $(this).attr("name");
                deleteLuminaire(name);
            });
        };
        this.luminaires = {};
        var updateList = this.updateList;
        $("#filter_luminaires").keyup(function () {
            updateList(this.value);
        });
        $("#elux_preview").on("click", function () {
            Utilities.sendAction("preview", "msg");
        });
        $("#elux_night_preview").on("click", function () {
            Utilities.sendAction("night_preview", "msg");
        });
        if (debug) {
            this.luminaires = {
                "Luminaire 1": {
                    "name": "Luminaire 1",
                    "manufacturer": "ERCO",
                    "lamp": "13W"
                },
                "Luminaire 2": {
                    "name": "Luminaire 2",
                    "manufacturer": "Philips",
                    "lamp": "13W"
                },
                "Luminaire 3": {
                    "name": "Luminaire 3",
                    "manufacturer": "ERCO",
                    "lamp": "3W"
                }
            };
        }
        else {
            this.luminaires = {};
        }
        this.updateList($("#filter_luminaires").val());
    }
    return LuminairesModule;
}());
//# sourceMappingURL=luminaires.js.map