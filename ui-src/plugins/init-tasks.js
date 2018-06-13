
var isDev = require("~/plugins/is-dev");

workplanes = [];    
tasks = [];

if(isDev){
    tasks.push({
      name: "Task 1",
      class: 'DF',
    });
      
    tasks.push({
      name: "Task 2",
      class: 'UDI',
    });    

    workplanes.push({
      name: "Small Kitchen", 
      pixel_size: 0.25,
      tasks:["Task 2","Task 1"]
    });
    
    workplanes.push({
      name: "Workplane with long name", 
      pixel_size: 0.25,
      tasks:["Task 2"]
    });
  
  
  }
  
  