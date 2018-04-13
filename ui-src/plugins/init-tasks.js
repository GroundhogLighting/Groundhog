if(require("~/plugins/is-dev")){
    tasks = [
      {name: "Task 1"},
      {name: "Task 2"},
    ];

    workplanes = [
        {name: "WP1", tasks: ["Task 2"]},
        {name: "WP2", tasks: ["Task 1"]}
    ]
    
  
  
  }else{  
    workplanes = [];
    tasks = [];
  }
  