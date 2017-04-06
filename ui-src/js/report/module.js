"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function Report() {
        var _this = this;
        this.update_objective_summary = function () {
            var div = $("#objective_summary");
            div.html("");
            var objs = Object.keys(DesignAssistant.objectives.objectives);
            for (var i = 0; i < objs.length; i++) {
                var newDiv = $("<div></div>");
                var name_1 = $("<h4>" + objs[i] + "</h4>");
                newDiv.append(name_1);
                var obj = DesignAssistant.objectives.objectives[objs[i]];
                DesignAssistant.objectives.parseObjective(obj);
                var metric = Utilities.getObjectiveType(obj.metric);
                var text = DesignAssistant.objectives.get_human_description(metric);
                var description = $("<p>" + text + "</p>");
                newDiv.append(description);
                div.append(newDiv);
            }
        };
        this.highlight_objective = function (objective) {
            $('#compliance_summary tr:first-child').each(function () {
                $(this).children().each(function () {
                    var o = $(this).text();
                    if (o == objective) {
                        $(this).addClass('selected');
                    }
                    else {
                        $(this).removeClass('selected');
                    }
                });
            });
        };
        this.update_elux_compliance_summary = function () {
            var table = $("#elux_compliance_summary");
            table.html("");
            var header = $("<tr><td></td><td>Average (lux)</td><td>Min/Average</td><td>Min/Max</td></tr>");
            table.append(header);
            for (var wp_name in _this.elux_results) {
                if (_this.elux_results.hasOwnProperty(wp_name)) {
                    var row = $("<tr></tr>");
                    var data = _this.elux_results[wp_name];
                    row.append($("<td>" + wp_name + "</td>"));
                    row.append($("<td>" + Math.round(data["average"]) + "</td>"));
                    row.append($("<td>" + Math.round(data["min_over_average"] * 100) / 100 + "</td>"));
                    row.append($("<td>" + Math.round(data["min_over_max"] * 100) / 100 + "</td>"));
                    table.append(row);
                }
            }
        };
        this.update_compliance_summary = function () {
            var table = $("#compliance_summary");
            table.html("");
            var objs = Object.keys(DesignAssistant.objectives.objectives);
            var header = $("<tr></tr>");
            header.append($("<td></td>"));
            for (var i = 0; i < objs.length; i++) {
                var name_2 = $("<td>" + objs[i] + "</td>");
                name_2.on("click", function () {
                    Utilities.sendAction("remark", $(this).text());
                });
                header.append(name_2);
            }
            table.append(header);
            for (var wp_name in _this.results) {
                if (_this.results.hasOwnProperty(wp_name)) {
                    var row = $("<tr></tr>");
                    row.append($("<td>" + wp_name + "</td>"));
                    for (var i = 0; i < objs.length; i++) {
                        var obj_name = objs[i];
                        var col = $("<td></td>");
                        if (_this.results[wp_name].hasOwnProperty(obj_name)) {
                            var s = _this.results[wp_name][obj_name] * 100;
                            col.text(Math.round(s) + "%");
                            if (DesignAssistant.objectives.objectives[obj_name]["goal"] <= s) {
                                col.addClass("success");
                            }
                            else {
                                col.addClass("not-success");
                            }
                        }
                        row.append(col);
                    }
                    table.append(row);
                }
            }
        };
        this.results = {};
        this.elux_results = {};
        $("#remark_elux").on("click", function () {
            Utilities.sendAction("remark", "ELUX");
        });
    }
    return Report;
}());
//# sourceMappingURL=module.js.map