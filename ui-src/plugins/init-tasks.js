if(require("~/plugins/is-dev")){
    tasks = [
      {
        name: "Task 1",
        class: 'DF',

      },
      {
        name: "Task 2",
        class: 'UDI',

      },
    ];

    workplanes = [
      {name: "Small Kitchen", pixel_size: 0.25,tasks:["Task 2","Task 1"]},
      {name: "Workplane with long name", pixel_size: 0.25,tasks:["Task 2"]},
  
    ]
    
  
  
  }else{  
    workplanes = [];
    tasks = [];
  }
  