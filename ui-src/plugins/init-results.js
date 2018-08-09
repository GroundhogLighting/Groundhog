
var isDev = require("~/plugins/is-dev");

global.project_results = [];    
global.scale = { min : 0, max : 100 };

if(isDev){
    project_results.push({ metric: "Task 2", workplane: "Small Kitchen", approved_percentage: 50});

    project_results.push({ metric: "Task 1", workplane: "Workplane with long name", approved_percentage: 50})

    project_results.push({ metric: "Imported Task", workplane: "WP 2", approved_percentage: 50});
    
    project_results.push({ metric: "Imported Task", workplane: "Small Kitchen", approved_percentage: 50})
}
  
  