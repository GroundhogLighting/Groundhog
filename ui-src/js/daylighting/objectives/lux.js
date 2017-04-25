"use strict";
var Lux = {
    metric: "LUX",
    name: "Illuminance under clear sky",
    dynamic: false,
    human_language: "Workplane is in compliance when at least %goal%% of the space presents an illuminance between %good_light_min%lux and %good_light_max%lux under a clear sky at %date_hour% hours on %date_date%.",
    good_light_legend: "Illuminance goal (lux)",
    requirements: [
        {
            name: "good_light",
            value: {
                "min": 300, "has_min": true, "max": 200, "has_max": true
            }
        },
        {
            name: "goal",
            value: 50
        },
        {
            name: "date",
            value: {
                "date": "",
                "hour": 12
            }
        }
    ]
};
module.exports = Lux;
//# sourceMappingURL=lux.js.map