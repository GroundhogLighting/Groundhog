"use strict";
var SkyVisibility = {
    metric: "SKY_VISIBILITY",
    name: "Sky Visibility",
    dynamic: false,
    human_language: "Workplane is in compliance when at least %goal%% of the space receives direct light from the sky.",
    good_light_legend: "Sky Visibility",
    requirements: [
        {
            name: "goal",
            value: 80
        }
    ]
};
module.exports = SkyVisibility;
//# sourceMappingURL=sky_visibility.js.map