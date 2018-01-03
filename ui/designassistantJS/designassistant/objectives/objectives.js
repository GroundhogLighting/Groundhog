"use strict";
var Utilities = require("../Utilities");
var Lux = require("./objectives/lux");
var DF = require("./objectives/df");
var UDI = require("./objectives/udi");
var DA = require("./objectives/da");
var SkyVisibility = require("./objectives/sky_visibility");
module.exports = (function () {
    function ObjectivesModule(debug) {
        var _this = this;
        this.metrics = [Lux, DF, UDI, DA, SkyVisibility];
        this.addObjective = function (wp_name, obj_name) {
            var message = { "workplane": wp_name, "objective": obj_name };
            Utilities.sendAction("add_objective", JSON.stringify(message));
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
            _this.updateList("");
            Utilities.sendAction("create_objective", JSON.stringify(objective));
            return { success: true };
        };
        this.removeObjective = function (workplane, objective) {
            Utilities.sendAction("remove_objective", JSON.stringify({ "workplane": workplane, "objective": objective }));
        };
        this.adapt_objective_dialog = function (metric_name) {
            var metric = Utilities.getObjectiveType(metric_name);
            $("#create_objective_dialog").children().hide();
            $("#objective_good_pixel").hide();
            $("label[for='objective_good_pixel']").hide();
            $("#objectiveName_field").show();
            $("#metric_field").show();
            $("#human_description").show();
            var _loop_1 = function (item) {
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
                    var req = Utilities.findOne(metric.requirements, function (e) {
                        return e.name === item.name;
                    });
                    $("#objective_" + item.name).val(req.name);
                }
            };
            for (var _i = 0, _a = metric.requirements; _i < _a.length; _i++) {
                var item = _a[_i];
                _loop_1(item);
            }
            $("#objective_good_light_legend").text(metric.good_light_legend);
        };
        this.get_objective_object = function (metric_name) {
            var ret = {};
            ret["name"] = $.trim($("#objectiveName").val());
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
        this.editWorkplane = function (workplaneName) {
            console.log("About to edit workplane " + workplaneName);
            return { success: true };
        };
        this.updateList = function (filter) {
            filter = filter.toLowerCase();
            var list = $("#objectives_list");
            list.html("");
            if (Object.keys(_this.objectives).length == 0) {
                $("<div class='center'><h4>There are no objectives in your model...</h4></div>").appendTo(list);
                return;
            }
            var objectives = $("<tr></tr>");
            objectives.append($("<td></td>"));
            var _loop_2 = function (objectiveName) {
                if (_this.objectives.hasOwnProperty(objectiveName)) {
                    if (objectiveName.toLowerCase().indexOf(filter) >= 0) {
                        var td = $(("<td name='" + objectiveName + "'>" + objectiveName + "</td>"));
                        objectives.append(td);
                        var checkBox = $("<input type='checkbox' name='" + objectiveName + "'>");
                        var editButton = $("<i name='" + objectiveName + "' class='material-icons edit-material'>mode_edit</i>");
                        var deleteButton = $("<i name='" + objectiveName + "' class='material-icons edit-material'>delete</i>");
                        td.append(checkBox);
                        td.append(deleteButton);
                        td.append(editButton);
                        checkBox.click(function () {
                            console.log("check | uncheck whole objective");
                        });
                        deleteButton.click(function () {
                            var objectiveName = $(this).attr("name");
                            Utilities.sendAction("delete_objective", objectiveName);
                        });
                        var editObjective_1 = _this.editObjective;
                        editButton.click(function () {
                            var objectiveName = $(this).attr("name");
                            editObjective_1(objectiveName);
                        });
                        objectives.append(td);
                    }
                }
            };
            for (var objectiveName in _this.objectives) {
                _loop_2(objectiveName);
            }
            list.append(objectives);
            var _loop_3 = function (workplaneName) {
                if (_this.workplanes.hasOwnProperty(workplaneName)) {
                    if (workplaneName.toLowerCase().indexOf(filter) >= 0) {
                        var tr_1 = $("<tr></tr>");
                        var td_1 = $(("<td name='" + workplaneName + "'>" + workplaneName + "</td>"));
                        tr_1.append(td_1);
                        var checkBox = $("<input type='checkbox' name='" + workplaneName + "'>");
                        var editButton = $("<i name='" + workplaneName + "' class='material-icons edit-material'>mode_edit</i>");
                        var deleteButton = $("<i name='" + workplaneName + "' class='material-icons edit-material'>delete</i>");
                        td_1.append(checkBox);
                        td_1.append(deleteButton);
                        td_1.append(editButton);
                        checkBox.click(function () {
                            console.log("check | uncheck whole workplane");
                        });
                        deleteButton.click(function () {
                            var workplaneName = $(this).attr("name");
                            Utilities.sendAction("delete_workplane", workplaneName);
                        });
                        var editWorkplane_1 = _this.editWorkplane;
                        editButton.click(function () {
                            var workplaneName = $(this).attr("name");
                            editWorkplane_1(workplaneName);
                        });
                        tr_1.append(td_1);
                        var a_1 = _this.workplanes[workplaneName];
                        objectives.children("td").each(function () {
                            var obj = $(this);
                            var objName = $(this).attr("name");
                            if (objName !== undefined) {
                                console.log(objName);
                                td_1 = $("<td></td>");
                                var check = $("<input type='checkbox' id='" + workplaneName + "|||" + objName + "'>");
                                var label = $("<label for='" + workplaneName + "|||" + objName + "'></label>");
                                if (a_1.indexOf(objName) > -1) {
                                    check.prop('checked', true);
                                }
                                else {
                                    check.prop('checked', false);
                                }
                                check.click(function () {
                                    var name = $(this).attr("id").split("|||");
                                    var msg = { workplane: name[0], objective: name[1] };
                                    if ($(this).is(':checked')) {
                                        Utilities.sendAction("add_objective_to_workplane", JSON.stringify(msg));
                                    }
                                    else {
                                        Utilities.sendAction("delete_objective_from_workplane", JSON.stringify(msg));
                                    }
                                });
                                td_1.append(check);
                                td_1.append(label);
                                tr_1.append(td_1);
                            }
                        });
                        list.append(tr_1);
                    }
                }
            };
            for (var workplaneName in _this.workplanes) {
                _loop_3(workplaneName);
            }
        };
        this.parseObjective = function (obj) {
            _this.adapt_objective_dialog(obj.metric);
            $("#metric").val(obj["metric"]);
            $("#objectiveName").val(obj.name);
            var metric = Utilities.getObjectiveType(obj.metric);
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
        };
        this.editObjective = function (objectiveName) {
            $("#objectiveName").prop("disabled", true);
            var obj = _this.objectives[objectiveName];
            var metric = Utilities.getObjectiveType(obj["metric"]);
            _this.parseObjective(obj);
            openDialog("add_objective_dialog");
        };
        if (debug) {
            this.objectives = {
                "DA(300,50%)": {
                    "name": "UDI(300-3000,50%)",
                    "metric": "DA",
                    "dynamic": true,
                    "good_pixel": 50,
                    "good_light": { "min": 300, "max": null },
                    "goal": 50, "occupied": { "min": 8, "max": 18 }, "sim_period": { "min": 1, "max": 12 }
                },
                "UDI(300-3000,50%)": {
                    "name": "UDI(300-3000,50%)",
                    "metric": "UDI",
                    "dynamic": true,
                    "good_pixel": 50,
                    "good_light": { "min": 300, "max": 3000 },
                    "goal": 50, "occupied": { "min": 8, "max": 18 }, "sim_period": { "min": 1, "max": 12 }
                },
                "DF 10%": {
                    "name": "DF 10%",
                    "metric": "DF",
                    "dynamic": false,
                    "good_pixel": 50,
                    "good_light": { "min": 300, "max": 3000 },
                    "goal": 50, "occupied": { "min": 8, "max": 18 }, "sim_period": { "min": 1, "max": 12 }
                }
            };
            this.workplanes = {
                "Basement": [],
                "1st Floor": [
                    "DA(300,50%)", "DF 10%"
                ]
            };
        }
        else {
            this.objectives = {};
            this.workplanes = {};
        }
        var create_objective = this.create_objective;
        this.add_objective_dialog = $("#create_objective_dialog");
        setOnSubmit(this.add_objective_dialog, create_objective);
        var adapt_objective_dialog = this.adapt_objective_dialog;
        $("#metric").on("change", function () {
            adapt_objective_dialog(this.value);
        });
        var add_objective_dialog = this.add_objective_dialog;
        $("#create_objective_button").on("click", function () {
            $("#objectiveName").removeAttr("disabled");
            openDialog("create_objective_dialog");
        });
        for (var _i = 0, _a = this.metrics; _i < _a.length; _i++) {
            var metric = _a[_i];
            $('#metric').append($('<option>', {
                value: metric.metric,
                text: metric.name
            }));
        }
        this.adapt_objective_dialog(this.metrics[0].metric);
        var updateList = this.updateList;
        $("#objectives_filter").keyup(function () {
            updateList(this.value);
        });
        this.updateList("");
    }
    return ObjectivesModule;
}());
//# sourceMappingURL=objectives.js.map