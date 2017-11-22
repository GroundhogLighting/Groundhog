import Utilities = require('../Utilities');
import { Response } from '../../common/core';

let DesignAssistant : any = {
    objectives : {}
};

export = class Report {

    results: any;
    elux_results: any;

    constructor(  ){
        this.results = {};        
        this.elux_results = {};

        $("#remark_elux").on("click",function(){
            Utilities.sendAction("remark","ELUX");
        })
    }

    
    update_objective_summary = () => {
        let div = $("#objective_summary");
        div.html("");
        let objs = Object.keys(DesignAssistant.objectives.objectives);

        for (let i = 0; i < objs.length; i++) {
            /* FIRST, its own div */
            let newDiv = $("<div></div>");
            let name = $("<h4>" + objs[i] + "</h4>");
            newDiv.append(name);
            let obj = DesignAssistant.objectives.objectives[objs[i]];
            DesignAssistant.objectives.parseObjective(obj);
            let metric = Utilities.getObjectiveType(obj.metric);
            let text = DesignAssistant.objectives.get_human_description(metric);            
            let description = $("<p>" + text + "</p>");
            newDiv.append(description);
            div.append(newDiv);
        }
    }

    highlight_objective = (objective: string) => {

        $('#compliance_summary tr:first-child').each(function () {
            $(this).children().each(function () {
                let o = $(this).text();
                if (o == objective) {
                    $(this).addClass('selected');
                } else {
                    $(this).removeClass('selected');
                }
            })
        });
    }

    update_elux_compliance_summary = () => {
        let table = $("#elux_compliance_summary");
        table.html("");
        let header = $("<tr><td></td><td>Average (lux)</td><td>Min/Average</td><td>Min/Max</td></tr>");
        table.append(header);
        for (let wp_name in this.elux_results) {
            if (this.elux_results.hasOwnProperty(wp_name)) {
                let row = $("<tr></tr>");
                let data = this.elux_results[wp_name];
                row.append($("<td>" + wp_name + "</td>"));
                row.append($("<td>" + Math.round(data["average"]) + "</td>"));
                row.append($("<td>" + Math.round(data["min_over_average"]*100)/100 + "</td>"));
                row.append($("<td>" + Math.round(data["min_over_max"]*100)/100 + "</td>"));
                table.append(row);
            }
        }
    }

    update_compliance_summary = () => {
        let table = $("#compliance_summary");
        table.html("");
        let objs = Object.keys(DesignAssistant.objectives.objectives);

        /* FIRST, ADD HEADER */
        let header = $("<tr></tr>");
        //empty column, where workplanes names will be written
        header.append($("<td></td>"));
        for (let i = 0; i < objs.length; i++) {
            let name = $("<td>" + objs[i] + "</td>");
            name.on("click", function () {
                Utilities.sendAction("remark",$(this).text());
            });
            header.append(name);
        }
        table.append(header);

        for (let wp_name in this.results) {
            if (this.results.hasOwnProperty(wp_name)) {
                let row = $("<tr></tr>");
                row.append($("<td>" + wp_name + "</td>"));

                for (let i = 0; i < objs.length; i++) {
                    let obj_name = objs[i];

                    let col = $("<td></td>");
                    if (this.results[wp_name].hasOwnProperty(obj_name)) {
                        let s = this.results[wp_name][obj_name] * 100;
                        col.text(Math.round(s) + "%");
                        if (DesignAssistant.objectives.objectives[obj_name]["goal"] <= s) {
                            col.addClass("success");
                        } else {
                            col.addClass("not-success");
                        }
                    }
                    row.append(col);
                }
                table.append(row);
            }
        }
    }

}