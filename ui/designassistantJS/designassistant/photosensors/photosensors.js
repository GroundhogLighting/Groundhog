"use strict";
var Utilities = require("../Utilities");
module.exports = (function () {
    function PhotosensorsModule(debug) {
        var _this = this;
        this.updateList = function (filter) {
            var list = $("#photosensor_list");
            list.html("");
            if (Object.keys(_this.photosensors).length == 0) {
                $("<div class='center'><h4>There are no photosensors in your model...</h4></div>").appendTo(list);
                return;
            }
            filter = filter.toLowerCase();
            var html = "<tr><td>Name</td><td></td></tr>";
            for (var sensor_name in _this.photosensors) {
                var sensor = _this.photosensors[sensor_name];
                if (sensor_name.toLowerCase().indexOf(filter) >= 0) {
                    html = html + "<tr>" +
                        "<td class='photosensor-name' name=\"" + sensor_name + "\">" + sensor_name + "</td>"
                        + "<td name='" + sensor_name + "'>"
                        + "<i name='" + sensor_name + "' class='material-icons edit-sensor'>mode_edit</i>"
                        + "<i name='" + sensor_name + "' class='material-icons del-sensor'>delete</i>"
                        + "</td>"
                        + "</tr>";
                }
            }
            "</tr>";
            list.html(html);
            var editSensor = _this.editSensor;
            $("i.edit-sensor").on("click", function () {
                var name = $(this).attr("name");
                Utilities.sendAction("enable_photosensor_tool", "");
                editSensor(name);
            });
            var deleteSensor = _this.deleteSensor;
            $("i.del-sensor").on("click", function () {
                var name = $(this).attr("name");
                deleteSensor(name);
            });
        };
        this.clearDialog = function () {
            $("#photosensor_name").val('');
            $("#photosensor_px").val("");
            $("#photosensor_py").val("");
            $("#photosensor_pz").val("");
            $("#photosensor_nx").val("");
            $("#photosensor_ny").val("");
            $("#photosensor_nz").val("");
        };
        this.deleteSensor = function (name) {
            if (_this.photosensors.hasOwnProperty(name)) {
                delete _this.photosensors[name];
                _this.updateList("");
                Utilities.sendAction('remove_photosensor', name);
            }
            else {
                alert("There is an error with the photosensor you are trying to remove!");
                return { success: false };
            }
            return { success: true };
        };
        this.editSensor = function (name) {
            if (_this.photosensors.hasOwnProperty(name)) {
                var sensor = _this.photosensors[name];
                $("#photosensor_name").val(name);
                $("#photosensor_name").prop("disabled", true);
                $("#photosensor_px").val(sensor.px);
                $("#photosensor_py").val(sensor.py);
                $("#photosensor_pz").val(sensor.pz);
                $("#photosensor_nx").val(sensor.nx);
                $("#photosensor_ny").val(sensor.ny);
                $("#photosensor_nz").val(sensor.nz);
            }
            else {
                alert("There is an error with the photosensor you are trying to edit!");
                return { success: false };
            }
            return { success: true };
        };
        this.addSensor = function (close) {
            var name = $.trim($("#photosensor_name").val());
            if (_this.photosensors.hasOwnProperty(name) && !$("#photosensor_name").prop("disabled")) {
                var r = confirm("A photosensor with this name already exists. Do you want to replace it?");
                if (!r) {
                    return false;
                }
            }
            else if (name == "") {
                alert("Please insert a valid name for the photosensor");
                return false;
            }
            var ps = {
                name: name,
                px: $("#photosensor_px").val(),
                py: $("#photosensor_py").val(),
                pz: $("#photosensor_pz").val(),
                nx: $("#photosensor_nx").val(),
                ny: $("#photosensor_ny").val(),
                nz: $("#photosensor_nz").val(),
            };
            for (var key in ps) {
                if (key === "name") {
                    continue;
                }
                if (ps[key] === "" || isNaN(ps[key])) {
                    alert("Please introduce a valid number for all inputs");
                    return;
                }
            }
            if (parseFloat(ps.nx) * parseFloat(ps.nx) + parseFloat(ps.ny) * parseFloat(ps.ny) + parseFloat(ps.nz) * parseFloat(ps.nz) < 0.0000001) {
                alert("Invalid normal values. They can't be all zero'");
                return;
            }
            _this.photosensors[name] = ps;
            if (close) {
                Utilities.sendAction("disable_active_tool", "");
            }
            Utilities.sendAction("add_photosensor", JSON.stringify(ps));
            _this.updateList("");
            return true;
        };
        this.photosensors = {};
        var addSensor = this.addSensor;
        $("#add_photosensor_button").on("click", function () {
            openDialog("add_photosensor_dialog");
        });
        this.addPhotosensorDialog = $("#add_photosensor_dialog");
        setOnSubmit(this.addPhotosensorDialog, function () {
            addSensor(true);
            Utilities.sendAction("disable_active_tool", "");
        });
        setOnCancel(this.addPhotosensorDialog, function () {
            Utilities.sendAction("disable_active_tool", "");
        });
        var updateList = this.updateList;
        $("#filter_photosensors").keyup(function () {
            updateList(this.value);
        });
        var addPhotosensorDialog = this.addPhotosensorDialog;
        var clearDialog = this.clearDialog;
        $("#add_photosensor_button").on("click", function () {
            clearDialog();
            $("#photosensor_name").prop("disabled", false);
            Utilities.sendAction("enable_photosensor_tool", "");
        });
        $("#add_photosensor_dialog :input").on("change", function () {
            if ($("#photosensor_name").prop("disabled")) {
                addSensor(false);
            }
        });
        if (debug) {
            this.photosensors = {
                "Sensor 1": {},
                "Sensor 2": {},
                "Sensor 3": {}
            };
        }
        else {
            this.photosensors = {};
        }
        this.updateList($("#filter_photosensors").val());
    }
    return PhotosensorsModule;
}());
//# sourceMappingURL=photosensors.js.map