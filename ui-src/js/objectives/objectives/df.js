"use strict";
var Df = {
    metric: "DF",
    name: "Daylight Factor",
    dynamic: false,
    human_language: "Workplane is in compliance when at least %goal%% of the space presents a Daylight Factor between %good_light_min%% and %good_light_max%%.",
    good_light_legend: "Daylight Factor goal (%)",
    requirements: [
        {
            name: "good_light",
            value: {
                "min": 2, "has_min": true, "max": 10, "has_max": true
            }
        },
        {
            name: "goal",
            value: 50
        }
    ]
};
module.exports = Df;
//# sourceMappingURL=df.js.map