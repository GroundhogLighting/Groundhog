"use strict";
var Utilities = require("../Utilities");
var Lux = require("./objectives/lux");
var DF = require("./objectives/df");
var UDI = require("./objectives/udi");
var DA = require("./objectives/da");
var SkyVisibility = require("./objectives/sky_visibility");
module.exports = (function () {
    function DaylightingModule() {
        var _this = this;
        this.metrics = [Lux, DF, UDI, DA, SkyVisibility];
        this.add_objective = function (wp_name, obj_name) {
            var message = { "workplane": wp_name, "objective": obj_name };
            Utilities.sendAction("add_objective", JSON.stringify(message));
        };
        this.get_human_description = function (metric) {
            var description = metric.human_language;
            var requirements = metric.requirements;
            for (var _i = 0, requirements_1 = requirements; _i < requirements_1.length; _i++) {
                var item = requirements_1[_i];
                if (item.value !== null && typeof item.value === 'object') {
                    for (var sub_item_name in item.value) {
                        if (item.value.hasOwnProperty(sub_item_name)) {
                            description = Utilities.replaceAll(description, "%" + item.name + "_" + sub_item_name + "%", $("#objective_" + item.name + "_" + sub_item_name).val());
                        }
                    }
                }
                else {
                    description = Utilities.replaceAll(description, "%" + item.name + "%", $("#objective_" + item.name).val());
                }
            }
            return description;
        };
        this.update_human_description = function () {
            var metric = $("#metric").val();
            metric = Utilities.getObjectiveType(metric);
            $("#objective_human_description").text(_this.get_human_description(metric));
        };
        this.create_objective = function () {
            var failure = { success: false };
            var metric = $("#metric").val();
            var res = _this.get_objective_object(metric);
            if (!res.success) {
                alert(res.error);
                return failure;
            }
            var objective = res.object;
            var name = objective["name"];
            if (_this.objectives.hasOwnProperty(name)) {
                var r = confirm("This objective already exists. Do you want to replace it?");
                if (!r) {
                    return failure;
                }
            }
            else if (name == "") {
                alert("Please insert a valid name for the objective");
                return failure;
            }
            _this.objectives[name] = objective;
            _this.update_objectives("");
            _this.add_objective_dialog.dialog("close");
            reportModule.update_objective_summary();
            Utilities.sendAction("create_objective", JSON.stringify(objective));
            return { success: true };
        };
        this.remove_objective = function (workplane, objective) {
            Utilities.sendAction("remove_objective", JSON.stringify({ "workplane": workplane, "objective": objective }));
        };
        this.adapt_objective_dialog = function (metric_name) {
            var metric = Utilities.getObjectiveType(metric_name);
            $("#create_objective_dialog").children().hide();
            $("#objective_good_pixel").hide();
            $("label[for='objective_good_pixel']").hide();
            $("#objective_name_field").show();
            $("#metric_field").show();
            $("#compliance_field").show();
            $("#human_description").show();
            for (var _i = 0, _a = metric.requirements; _i < _a.length; _i++) {
                var item = _a[_i];
                $("#objective_" + item.name).show();
                $("label[for='objective_" + item.name + "']").show();
                if (item.value !== null && typeof item.value === 'object') {
                    for (var sub_item_name in item.value) {
                        if (item.value.hasOwnProperty(sub_item_name)) {
                            var sub_item = item.value[sub_item_name];
                            $("#objective_" + item.name + "_" + sub_item_name).val(sub_item);
                        }
                    }
                }
                else {
                    $("#objective_" + item.name).val(metric.requirements[item.name]);
                }
            }
            $("#objective_good_light_legend").text(metric.good_light_legend);
            _this.update_human_description();
        };
        this.get_objective_object = function (metric_name) {
            var ret = {};
            ret["name"] = $.trim($("#objective_name").val());
            ret["metric"] = metric_name;
            var metric = Utilities.getObjectiveType(metric_name);
            ret["dynamic"] = metric.dynamic;
            for (var _i = 0, _a = metric.requirements; _i < _a.length; _i++) {
                var item = _a[_i];
                if (item.value !== null && typeof item.value === 'object') {
                    ret[item.name] = {};
                    for (var sub_item_name in item.value) {
                        if (item.value.hasOwnProperty(sub_item_name)) {
                            var input = $("#objective_" + item.name + "_" + sub_item_name);
                            ret[item.name][sub_item_name] = input.val();
                            if (input.attr("type") === "number") {
                                ret[item.name][sub_item_name] = parseFloat(ret[item.name][sub_item_name]);
                            }
                        }
                    }
                }
                else {
                    ret[item.name] = parseFloat($("#objective_" + item.name).val());
                }
            }
            $("#objective_good_light_legend").text(metric.good_light_legend);
            return { success: true, object: ret };
        };
        this.update_objectives = function (filter) {
            var list = $("#objectives_list");
            list.html("");
            if (Object.keys(_this.objectives).length == 0) {
                $("<div class='center'><h4>There are no objectives in your model...</h4></div>").appendTo(list);
                return;
            }
            filter = filter.toLowerCase();
            for (var objective in _this.objectives) {
                if (_this.objectives.hasOwnProperty(objective)) {
                    if (objective.toLowerCase().indexOf(filter) >= 0) {
                        var new_row = $("<tr></tr>");
                        var drag = $(("<td name='" + objective + "'>" + objective + "</td>"));
                        new_row.append(drag);
                        var action_column = $("<td></td>");
                        var delete_button = $("<span name=\"" + objective + "\" class='ui-icon ui-icon-trash del-material'></span>");
                        var edit_button = $("<span name=\"" + objective + "\" class='ui-icon ui-icon-pencil edit-material'></span>");
                        delete_button.on("click", function () {
                            var objective_name = $(this).attr("name");
                            Utilities.sendAction("delete_objective", objective_name);
                        });
                        edit_button.on("click", function () {
                            var objective_name = $(this).attr("name");
                            this.editObjective(objective_name);
                        });
                        new_row.append(action_column);
                        action_column.append(edit_button);
                        action_column.append(delete_button);
                        drag.draggable({
                            appendTo: "body",
                            helper: "clone"
                        });
                        list.append(new_row);
                    }
                }
            }
        };
        this.editObjective = function (objective_name) {
            $("#objective_name").prop("disabled", true);
            var obj = _this.objectives[objective_name];
            var metric = Utilities.getObjectiveType(obj["metric"]);
            _this.adapt_objective_dialog(metric.metric);
            $("#metric").val(obj["metric"]);
            $("#objective_name").val(obj["name"]);
            for (var _i = 0, _a = metric.requirements; _i < _a.length; _i++) {
                var item = _a[_i];
                if (item.value !== null && typeof item.value === 'object') {
                    for (var sub_item_name in item.value) {
                        if (item.value.hasOwnProperty(sub_item_name)) {
                            $("#objective_" + item.name + "_" + sub_item_name).val(obj[item.name][sub_item_name]);
                        }
                    }
                }
                else {
                    $("#objective_" + item.name).val(obj[item.name]);
                }
            }
            _this.add_objective_dialog.dialog("open");
        };
        this.get_new_row_for_workplane = function (workplane, objective) {
            var row = $("<tr></tr>");
            var name_column = $("<td>" + objective + "</td>");
            row.append(name_column);
            var actions_column = $("<td></td>");
            var delete_button = $("<span name='" + workplane + "' title='" + objective + "' class='ui-icon ui-icon-trash del-objective'></span>");
            delete_button.on("click", function () {
                var wp = $(this).attr("name");
                var obj = $(this).parent().siblings("td").text();
                this.remove_objective(wp, obj);
            });
            actions_column.append(delete_button);
            row.append(actions_column);
            return row;
        };
        this.update_workplanes = function (filter) {
            var ul = $("#workplane_objectives");
            ul.html("");
            if (Object.keys(_this.workplanes).length === 0) {
                $("<div class='center'><h4>There are no workplanes in your model...</h4></div>").appendTo(ul);
                return;
            }
            filter = filter.toLowerCase();
            for (var wp_name in _this.workplanes) {
                if (_this.workplanes.hasOwnProperty(wp_name)) {
                    if (wp_name.toLowerCase().indexOf(filter) >= 0) {
                        var li = $("<li></li>");
                        var title = $("<h1></h1>");
                        title.text(wp_name);
                        li.append(title);
                        li.droppable({
                            hoverClass: "hover",
                            accept: ":not(.ui-sortable-helper)",
                            drop: function (event, ui) {
                                if ("TD" != ui.draggable.prop("tagName")) {
                                    alert(ui.draggable.prop("tagName"));
                                    return;
                                }
                                ;
                                var wp_name = $(this).find("h1").text();
                                var table_name = Utilities.fixName(wp_name) + "_objectives";
                                var objective = ui.draggable.attr("name");
                                if (this.workplanes[wp_name].indexOf(objective) >= 0) {
                                    alert("That workplane has already been assigned that objective!");
                                    return;
                                }
                                var new_row = this.get_new_row_for_workplane(wp_name, objective);
                                var table = $("#" + table_name);
                                if (table.length == 0) {
                                    $(this).find("div").remove();
                                    table = $("<table id='" + table_name + "'></table>");
                                    table.appendTo($(this));
                                }
                                new_row.appendTo(table);
                                this.workplanes[wp_name].push(objective);
                                this.add_objective(wp_name, objective);
                            }
                        });
                        ul.append(li);
                        var objectives = _this.workplanes[wp_name];
                        if (objectives.length == 0) {
                            li.append($("<div>Drop objectives here</div>"));
                            li.addClass("empty");
                        }
                        else {
                            var table = $("<table id='" + Utilities.fixName(wp_name) + "_objectives'>");
                            for (var i = 0; i < objectives.length; i++) {
                                var row = _this.get_new_row_for_workplane(wp_name, objectives[i]);
                                table.append(row);
                            }
                            li.append(table);
                        }
                    }
                }
            }
        };
        this.objectives = {};
        this.workplanes = {};
        var create_objective = this.create_objective;
        this.add_objective_dialog = $("#create_objective_dialog").dialog({
            autoOpen: false,
            modal: true,
            buttons: {
                "Create objective": create_objective,
                Cancel: function () {
                    $(this).dialog("close");
                }
            },
            height: 0.8 * $(window).height(),
            width: 0.6 * $(window).width()
        });
        $("#set_low_parameters").on("click", function () {
            $("#ray_tracing_parameters").val("-ab 4 -ad 1000 -lw 1e-3");
            $("#elux_ray_tracing_parameters").val("-ab 4 -ad 1000 -lw 1e-3");
            $("#dc_parameters").val("-ab 4 -ad 1000 -lw 1e-3");
        });
        $("#set_med_parameters").on("click", function () {
            $("#ray_tracing_parameters").val("-ab 7 -ad 3000 -lw 1e-4");
            $("#elux_ray_tracing_parameters").val("-ab 7 -ad 3000 -lw 1e-4");
            $("#dc_parameters").val("-ab 7 -ad 3000 -lw 1e-4");
        });
        $("#set_high_parameters").on("click", function () {
            $("#ray_tracing_parameters").val("-ab 9 -ad 9999 -lw 1e-5");
            $("#elux_ray_tracing_parameters").val("-ab 9 -ad 9999 -lw 1e-5");
            $("#dc_parameters").val("-ab 9 -ad 9999 -lw 1e-5");
        });
        $("#set_low_tdd").on("click", function () {
            $("#tdd_daylight_parameters").val("-ab 3 -ad 512 -lw 1e-3");
            $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
            $("#tdd_view_parameters").val("-ab 3 -ad 512 -lw 1e-3");
        });
        $("#set_med_tdd").on("click", function () {
            $("#tdd_daylight_parameters").val("-ab 3 -ad 512 -lw 1e-3");
            $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
            $("#tdd_view_parameters").val("-ab 3 -ad 512 -lw 1e-3");
        });
        $("#set_high_tdd").on("click", function () {
            $("#tdd_daylight_parameters").val("-ab 3 -ad 1000 -lw 1e-3");
            $("#tdd_pipe_parameters").val("-ab 4 -ad 128 -lw 1e-2");
            $("#tdd_view_parameters").val("-ab 6 -ad 5512 -lw 1e-5");
        });
        $("#simulate_button").on("click", function () {
            var options = {};
            $("#simulation_options *").each(function () {
                var title = $(this).attr("title");
                if (title && title == "option") {
                    if ($(this).is("input[type=checkbox]")) {
                        var id = $(this).attr("id");
                        var state = $('#' + id).is(":checked");
                        options[id] = state;
                    }
                    else {
                        options[$(this).attr("id")] = $(this).val();
                    }
                }
            });
            Utilities.sendAction("calculate", JSON.stringify(options));
        });
        var update_workplanes = this.update_workplanes;
        $("#workplane_objectives_filter").keyup(function () {
            update_workplanes(this.value);
        });
        var adapt_objective_dialog = this.adapt_objective_dialog;
        $("#metric").on("change", function () {
            adapt_objective_dialog(this.value);
        });
        var add_objective_dialog = this.add_objective_dialog;
        $("#create_objective_button").button().on("click", function () {
            $("#objective_name").removeAttr("disabled");
            add_objective_dialog.dialog("open");
        });
        $("#objective_date_date").datepicker();
        var update_human_description = this.update_human_description;
        $(".resizable1").resizable({
            autoHide: true,
            handles: 'e',
            resize: function (e, ui) {
                var parent = ui.element.parent();
                var remainingSpace = parent.width() - ui.element.outerWidth(), divTwo = ui.element.next(), divTwoWidth = (remainingSpace - divTwo.outerWidth() + divTwo.width()) / parent.width() * 98 + "%";
                divTwo.width(divTwoWidth);
            },
            stop: function (e, ui) {
                var parent = ui.element.parent();
                ui.element.css({
                    width: ui.element.width() / parent.width() * 100 + "%",
                });
            }
        });
        $("#create_objective_dialog input").change(function () {
            update_human_description();
        });
        for (var _i = 0, _a = this.metrics; _i < _a.length; _i++) {
            var metric = _a[_i];
            $('#metric').append($('<option>', {
                value: metric.metric,
                text: metric.name
            }));
        }
        this.adapt_objective_dialog(this.metrics[0].metric);
        var update_objectives = this.update_objectives;
        $("#objectives_filter").keyup(function () {
            update_objectives(this.value);
        });
        this.update_objectives("");
        this.update_workplanes("");
    }
    return DaylightingModule;
}());
//# sourceMappingURL=module.js.map