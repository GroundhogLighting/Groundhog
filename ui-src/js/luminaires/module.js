"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function LuminairesModule() {
        var _this = this;
        this.useLuminaire = function (name) {
            var msg = _this.luminaires[name];
            msg["name"] = name;
            Utilities.sendAction("use_luminaire", JSON.stringify(msg));
        };
        this.deleteLuminaire = function (name) {
            alert("Deleting " + name);
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
            for (var _i = 0, _a = _this.luminaires; _i < _a.length; _i++) {
                var luminaire = _a[_i];
                var desc = luminaire.luminaire;
                var manufacturer = luminaire.manufacturer;
                var lamp = luminaire.lamp;
                if (luminaire.name.toLowerCase().indexOf(filter) >= 0 ||
                    manufacturer.toLowerCase().indexOf(filter) >= 0 ||
                    lamp.toLowerCase().indexOf(filter) >= 0) {
                    html = html + "<tr><td class='luminaire-name' name=\"" + luminaire.name + "\">" + luminaire.name + "</td><td>" + manufacturer + "</td><td>" + lamp + "</td></tr>";
                }
            }
            list.html(html);
            $("td.luminaire-name").on("click", function () {
                var name = $(this).attr("name");
                this.useLuminaire(name);
            });
            $("span.del-luminaire").on("click", function () {
                var name = $(this).attr("name");
                this.deleteLuminaire(name);
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
        this.updateList("");
    }
    return LuminairesModule;
}());
//# sourceMappingURL=module.js.map