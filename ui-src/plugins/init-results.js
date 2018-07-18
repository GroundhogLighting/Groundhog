
var isDev = require("~/plugins/is-dev");

project_results = [];    
scale = { min : 0, max : 100 };

if(isDev){
    project_results.push({ metric: "Task 2", workplane: "Small Kitchen", approved_percentage: 50});

    project_results.push({ metric: "Task 1", workplane: "Workplane with long name", approved_percentage: 50})
}
  
  