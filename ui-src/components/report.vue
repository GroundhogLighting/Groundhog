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
            v-for="(wp, wp_index) in workplanes" 
            :key="wp_index"            
            >{{wp.name | limitString(7)}}</td>
        </tr>
      </thead>

      <tbody>
        <tr 
          class="selectable"
          v-for="(task, task_index) in tasks" 
          :key="task_index"
          v-on:click="selectTask(task.name)"
          v-bind:class="{selected : selectedTask == task.name}"
          >
          <td>{{task.name | limitString(7) }}</td>
          
          <td v-for="(wp, wp_index) in workplanes" 
              :key="wp_index"   
          >{{ results_object[task.name][wp.name] | round(0)}} </td>          

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
      rgb(8,46,65) ,
      rgb(43,117,204),
      rgb(234,231,214),
      rgb(238,195,82),
      rgb(218,37,54));
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

      var matchTaskValue = function(taskName,wpName){

        for(var i=0; i< results.length; i++){
          var item = results[i];
          if(taskName === item.metric && wpName === item.workplane){
            return item.approved_percentage;
          }
        }

        return null;
      }

      var ret = {};
      for(var i=0; i<tasks.length; i++){
        var taskName = tasks[i].name;
        ret[taskName] = {};
        for(var j = 0; j < workplanes.length; j++){
          var wpName = workplanes[j].name;
          ret[taskName][wpName] = matchTaskValue(taskName,wpName);          
        }
      }
      return ret;
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

