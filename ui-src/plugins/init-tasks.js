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
      {name: "WP1", pixel_size: 0.25,tasks:["Task 2","Task 1"]},
      {name: "WP2", pixel_size: 0.25,tasks:["Task 2"]},
  
    ]
    
  
  
  }else{  
    workplanes = [];
    tasks = [];
  }
  