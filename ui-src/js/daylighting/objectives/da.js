"use strict";
var Da = {
    metric: "DA",
    name: "Daylight Autonomy",
    dynamic: true,
    human_language: "Workplane is in compliance when at least %goal%% of the space achieves an illuminance of %good_light_min%lux or more for a minimum of %good_pixel%% of the occupied time by daylight only. Occupied time is between %occupied_min% and %occupied_max% hours, from months %sim_period_min% to %sim_period_max%.",
    good_light_legend: "Illuminance goal (lux)",
    requirements: [
        {
            name: "good_pixel",
            value: 50
        },
        {
            name: "good_light",
            value: { "min": 300, "has_min": true, "has_max": false, "max": false }
        },
        {
            name: "goal",
            value: 50
        },
        {
            name: "occupied",
            value: { "min": 8, "has_min": true, "has_max": true, "max": 18 }
        },
        {
            name: "sim_period",
            value: { "min": 1, "has_min": true, "has_max": true, "max": 12 }
        }
    ],
};
module.exports = Da;
//# sourceMappingURL=da.js.map