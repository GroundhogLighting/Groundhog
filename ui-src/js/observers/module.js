"use strict";
var Utilities = require("../utilities");
module.exports = (function () {
    function ObserversModule() {
        var _this = this;
        this.updateList = function (filter) {
            var list = $("#observer_list");
            list.html("");
            if (Object.keys(_this.observers).length == 0) {
                $("<div class='center'><h4>There are no observers in your model...</h4></div>").appendTo(list);
                return;
            }
            filter = filter.toLowerCase();
            var html = "<tr><td>Name</td><td></td></tr>";
            for (var observer_name in _this.observers) {
                console.log("aa");
                var observer = _this.observers[observer_name];
                if (observer_name.toLowerCase().indexOf(filter) >= 0) {
                    html = html + "<tr><td class='observer-name' name=\"" + observer_name + "\">" + observer_name + "</td>";
                    html = html + "<td class='icons'><span name=\"" + observer_name + "\" class='ui-icon ui-icon-trash del-observer'></span><span name=\"" + observer_name + "\" class='ui-icon ui-icon-pencil edit-observer'></span><span name=\"" + observer_name + "\" class='ui-icon ui-icon-circle-zoomin view-observer'></span></td>";
                }
            }
            html += "</tr>";
            list.html(html);
            var editObserver = _this.editObserver;
            $("span.edit-observer").on("click", function () {
                var name = $(this).attr("name");
                editObserver(name);
            });
            var deleteObserver = _this.deleteObserver;
            $("span.del-observer").on("click", function () {
                var name = $(this).attr("name");
                deleteObserver(name);
            });
            var viewObserver = _this.viewObserver;
            $("span.view-observer").on("click", function () {
                var name = $(this).attr("name");
                viewObserver(name);
            });
        };
        this.clearDialog = function () {
            $("#observer_name").val('');
            $("#observer_px").val("");
            $("#observer_py").val("");
            $("#observer_pz").val("");
            $("#observer_nx").val("");
            $("#observer_ny").val("");
            $("#observer_nz").val("");
        };
        this.deleteObserver = function (name) {
            if (_this.observers.hasOwnProperty(name)) {
                delete _this.observers[name];
                _this.updateList("");
                Utilities.sendAction('remove_observer', name);
            }
            else {
                alert("There is an error with the observer you are trying to remove!");
                return { success: false };
            }
            return { success: true };
        };
        this.editObserver = function (name) {
            if (_this.observers.hasOwnProperty(name)) {
                var observer = _this.observers[name];
                $("#observer_name").val(name);
                $("#observer_name").prop("disabled", true);
                $("#observer_px").val(observer.px);
                $("#observer_py").val(observer.py);
                $("#observer_pz").val(observer.pz);
                $("#observer_nx").val(observer.nx);
                $("#observer_ny").val(observer.ny);
                $("#observer_nz").val(observer.nz);
            }
            else {
                alert("There is an error with the observer you are trying to edit!");
                return { success: false };
            }
            _this.addObserverDialog.dialog("open");
            return { success: true };
        };
        this.addObserver = function () {
            var name = $.trim($("#observer_name").val());
            if (_this.observers.hasOwnProperty(name)) {
                var r = confirm("A observer with this name already exists. Do you want to replace it?");
                if (!r) {
                    return false;
                }
            }
            else if (name == "") {
                alert("Please insert a valid name for the observer");
                return false;
            }
            var ps = {
                name: name,
                px: $("#observer_px").val(),
                py: $("#observer_py").val(),
                pz: $("#observer_pz").val(),
                nx: $("#observer_nx").val(),
                ny: $("#observer_ny").val(),
                nz: $("#observer_nz").val(),
            };
            _this.observers[name] = ps;
            _this.addObserverDialog.dialog("close");
            Utilities.sendAction("addObserver", JSON.stringify(ps));
            _this.updateList("");
            return true;
        };
        this.viewObserver = function (name) {
            if (_this.observers.hasOwnProperty(name)) {
                var observer = _this.observers[name];
                Utilities.sendAction("go_to_view", JSON.stringify(observer));
            }
            else {
                alert("There is an error with the observer you are trying to view!");
                return { success: false };
            }
        };
        this.observers = {};
        var addObserver = this.addObserver;
        this.addObserverDialog = $("#add_observer_dialog").dialog({
            autoOpen: false,
            modal: true,
            buttons: {
                "Create objective": addObserver,
                Cancel: function () {
                    $(this).dialog("close");
                }
            },
            height: 0.8 * $(window).height(),
            width: 0.6 * $(window).width()
        });
        var updateList = this.updateList;
        $("#filter_observers").keyup(function () {
            updateList(this.value);
        });
        var addObserverDialog = this.addObserverDialog;
        var clearDialog = this.clearDialog;
        $("#add_observer_button").button().on("click", function () {
            clearDialog();
            $("#observer_name").prop("disabled", false);
            addObserverDialog.dialog("open");
        });
        this.updateList("");
    }
    return ObserversModule;
}());
//# sourceMappingURL=module.js.map