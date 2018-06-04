<template>
  <div v-container v-with-sidenav>  
    <a-navbar fixed variant="primary">        
      <a-input :label="'Filter'" :type="'text'"/>
      <a-button :variant="'primary'">Create task</a-button>
    </a-navbar>
    
    
      <!-- NO TASKS MESSAGE -->
      <span class="no-data" v-show="!tasks || tasks.length == 0">There are no tasks in your model</span>        
      <a-check-table v-model="workplanes" :rows="taskNames"></a-check-table>
  </div>
</template>

<script>


import "~/plugins/init-tasks"
import SKPHelper from "~/plugins/skp-helper";

export default {  
  computed : {    
    taskNames: function(){
      return this.tasks.map(function(x){
        return x.name;
      })
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
