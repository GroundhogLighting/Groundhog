if(require("~/plugins/is-dev")){
    tasks = [
      {name: "Task 1"},
      {name: "Task 2"},
    ];

    workplanes = {
        "WP1" : ["Task 2"],
        "WP2" : ["Task 1"]
    };
    
  
  
  }else{  
    workplanes = [];
    tasks = [];
  }
  