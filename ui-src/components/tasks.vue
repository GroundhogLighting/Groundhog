<template>
  <div>
    <md-navbar fixed variant="primary">        
      <input type="text" placeholder="Filter"/>
      <a href="#">Create task</a>
    </md-navbar>
    
    <div class="view-container"> 
      <!-- NO TASKS MESSAGE -->
      <span class="sorry" v-show="!tasks || tasks.length == 0">There are no tasks in your model</span>  
      
      <table v-show="tasks.length > 0" class="selectable-cell">
        <thead>
          <tr>
            <td></td>
            <td v-for="t in tasks" :key=t.name><i class="material-icons">mode_edit</i>{{t.name}}</td>            
          </tr>  
        </thead>
        
        <tbody>
          <tr v-for="wp in workplanes" :key=wp.name>
            <td><i class="material-icons">mode_edit</i>{{wp.name}}</td>
            <td v-on:click="toggleTask(wp,t.name)" class="clickable" v-for="t in tasks" :key=t.name>
              <i v-show="includes(wp,t.name)" class="material-icons">check_box</i>
              <i v-show="!includes(wp,t.name)" class="material-icons">check_box_outline_blank</i>     
            </td>       
          </tr>
        </tbody>
      </table>
    </div>

  </div>
</template>

<script>


import "~/plugins/init-tasks"
import SKPHelper from "~/plugins/skp-helper";

export default {  
  methods : {    
    includes(wp,taskName){
      return wp.tasks.indexOf(taskName) > -1;
    },
    toggleTask(wp,taskName){
      if(this.includes(wp,taskName)){
        var array = wp.tasks;
        for (var i=array.length-1; i>=0; i--) {
          if (array[i] === taskName) {
              array.splice(i, 1);
              break;       
          }
      }
      }else{
        wp.tasks.push(taskName);
      }
    }
  },
  data () {
    return {
      tasks: tasks,
      workplanes: workplanes,
      skp : SKPHelper
    }
  }
}
  
  
</script>
