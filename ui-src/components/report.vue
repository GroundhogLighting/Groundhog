<template>
  <div v-container v-with-sidenav>  
    
    <span v-show="results.length == 0" class='no-data' >There is no data to report...</span>  
    
    <a-table v-show="results.length != 0"  id="scale-table">
      <thead></thead>
      <tbody>
        <tr>
          <a-editable-cell @submitCell="changeScale()" v-model="scale.min"></a-editable-cell>
          <td id="scale-image"></td>
          <a-editable-cell @submitCell="changeScale()" v-model="scale.max"></a-editable-cell>
        </tr>
      </tbody>
    </a-table>

    <a-double-entry-table v-show="results.length != 0">
      <thead>
        <tr>
          <td></td><td             
            v-for="(wp, wp_index) in solved_workplanes" 
            :key="wp_index"            
            >{{wp | limitString(7)}}</td>
        </tr>
      </thead>

      <tbody>
        <tr 
          class="selectable"
          v-for="(task, task_index) in solved_tasks" 
          :key="task_index"
          v-on:click="selectTask(task)"
          v-bind:class="{selected : selectedTask == task}"
          >
          <td>{{task | limitString(7) }}</td>
          
          <td v-for="(wp, wp_index) in solved_workplanes" 
              :key="wp_index"   
          >{{ (results_object[task] ? results_object[task][wp] : 0) | round(0) }} </td>          

        </tr>
      </tbody>
    </a-double-entry-table>

  </div>
</template>

<style lang="scss">
  #scale-table{
    margin-left:auto;
    margin-right:auto;
    margin-bottom: 20px;
    
    tr{
      td{
        padding : 5px 10px;
        border-bottom: none;
      }      
    }


    #scale-image{
      width: 200px;
      background: linear-gradient(to right, 
      rgb(68,13,84),
      rgb(72,21,104),
      rgb(72,38,119),
      rgb(69,55,129),
      rgb(63,71,136),
      rgb(57,85,140),
      rgb(50,100,142),
      rgb(45,112,142),
      rgb(39,125,142),
      rgb(35,138,141),
      rgb(31,150,139),
      rgb(32,163,134),
      rgb(41,175,127),
      rgb(60,188,117),
      rgb(86,198,103),
      rgb(116,208,85),
      rgb(148,216,64),
      rgb(184,222,41),
      rgb(220,227,23),
      rgb(253,231,37)
      )
    }
  }
      

  tr.selected{          
    
    background-color: darken(#f5f5f5,7);
    
  }
</style>


<script>

import "~/plugins/init-results";
import SKPHelper from "~/plugins/skp-helper";

export default {
  computed : {
    results_object : function(){

      var results = this.results;
      var ret = {};

      for(var i=0; i<results.length; i++){
        const taskName = results[i].metric;
        const wpName = results[i].workplane;
        const value = results[i].approved_percentage;
        if(!ret[taskName]){
          ret[taskName] = {}
        }
        ret[taskName][wpName] = value
      }      

      return ret;

    },
    solved_workplanes : function(){
      return unique(this.results.map(function(r){return r.workplane}));
    },
    solved_tasks : function(){
      return unique(this.results.map(function(r){return r.metric}));
    }
  },
  methods : {
    selectTask: function(taskName){
      this.selectedTask = taskName;
      this.skp.call_action('show_task_results',taskName);
    },
    changeScale : function(){
      var taskName = this.selectedTask;
      var min = this.scale.min;
      var max = this.scale.max;

      
      
      if(taskName === undefined || taskName === ""){
        var t = this.tasks[0];
        if(t === undefined){
          alert("Please select a task");
        }
        taskName = t.name;        
        this.selectTask(taskName);        
      }
      var ret = {
        task: taskName, min: parseFloat(min), max: parseFloat(max)
      }
      this.skp.call_action('update_scale',ret)
    }
    
  },
  data(){
    return{
      results: project_results,
      workplanes: workplanes,
      tasks: tasks,
      skp: SKPHelper,
      selectedTask: "",
      scale : scale
    }
  }

}

SKPHelper.call_action('load_results','');
</script>

