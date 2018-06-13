<template>
  <div v-container v-with-sidenav>  
    <a-navbar fixed variant="primary">        
      <a-input :label="'Filter'" :type="'text'"/>
      <a-button :variant="'primary'" v-on:click.native="createTask">Create task</a-button>
    </a-navbar>
    
    
      <!-- NO TASKS MESSAGE -->
      <span class="no-data" 
            v-show="(!tasks || tasks.length === 0) && (!workplanes || workplanes.length === 0) ">
            There are no tasks or workplanes in your model
      </span>              

      <task-table 
        v-show="(tasks && tasks.length !== 0) || (workplanes && workplanes.length !== 0) "
        :workplanes="workplanes"
        :tasks="tasks" 

        v-on:removeWP="removeWP"
        v-on:editWP="editWP"
        v-on:check="check"
        v-on:removeTask="removeTask"
        v-on:editTask="editTask"
        
        
      ></task-table>

      <!-- EDIT TASK DIALOG -->
      <a-dialog :actions="{'Accept' : submitEditTask}" ref='taskEditor' :title="'Task editor'"  @close="selectedTask = {}">        
        <form>
          <a-input :label="'Name'" v-model="selectedTask.name"></a-input>
          <br>
          <a-select v-model="selectedTask.class" :options="Object.keys(taskProps)"></a-select>
          <br>
          <div v-for="(item, index) in taskProps[selectedTask.class]" :key="index">
            <a-input  
              :type="'number'" 
              :required="true"                 
              :max="item.max"
              :min="item.min"              
              v-model="selectedTask[index]"               
              :label="index">
          </a-input>
            <br>  
          </div>    
          
        </form>
      </a-dialog>

      <!-- EDIT WORKPLANE DIALOG -->
      <a-dialog :actions="{'Accept' : submitEditWorkplane}" ref='workplaneEditor' :title="'Workplane editor'"  @close="selectedWorkplane = {}">        
        <div class='form'>
          <a-table>
            <thead>

            </thead>
            <tbody>
              <tr>
                <td>Name</td>
                
                <a-editable-cell v-model="selectedWorkplane.name"></a-editable-cell>  
                
              </tr>
              <tr>
                <td>Desired pixel size</td>
                <a-editable-cell v-model="selectedWorkplane.pixel_size"></a-editable-cell>  
              </tr>
            </tbody>
          </a-table>
        
        </div>
      </a-dialog>

  </div>
</template>

<script>


import "~/plugins/init-tasks"
import SKPHelper from "~/plugins/skp-helper";
import TaskTable from "./others/task-table";

const taskProperties = {
  UDI : {
    min_lux : {default: 300, min: 0},
    max_lux : {default: 3000, min: 0},
    early : {default: 8, min: 0, max: 24},
    late : {default: 18, min: 0, max: 24},
    min_month : {default: 0, min: 1, max: 12},
    max_month : {default: 12, min: 1, max: 12},
    min_time: {default: 50, min: 0, max: 100}
  },
  DA : {
    min_lux : {default: 300, min: 0},
    early : {default: 8, min: 0, max: 24},
    late : {default: 18, min: 0, max: 24},
    min_month : {default: 0, min: 1, max: 12},
    max_month : {default: 12, min: 1, max: 12},
    min_time: {default: 50, min: 0, max: 100}
  },
  DF: {
    min_percent: {default: 3, min: 0, max: 100}
  }
}

export default {  
  computed : {    
    taskNames: function(){
      return this.tasks.map(function(x){
        return x.name;
      })
    },
  },
  components : {
    TaskTable : TaskTable
  },
  methods : {
    removeWP: function(wpName){
      this.skp.call_action('remove_workplane',wpName);
    },
    editWP: function(wpName,newWP){
      var wp = workplanes.find(function(e){return e.name == wpName});
      this.selectedWorkplane = Object.assign({oldName: wp.name},wp);
      this.$refs.workplaneEditor.show();
    },
    check: function(taskName,wpName){
      this.skp.call_action('match_task_and_wp',{task: taskName, workplane: wpName});
    },
    removeTask: function(taskName){
      this.skp.call_action('remove_task',taskName);
    },    
    createTask: function(){
      
      this.$refs.taskEditor.show()
    },
    editTask: function(taskName,newTask){
      var task = tasks.find(function(e){return e.name == taskName});
      this.selectedTask = Object.assign({oldName : task.name},task);      
      this.$refs.taskEditor.show();
    },
    submitEditWorkplane : function(){
      
      var newWP = this.selectedWorkplane;
      var oldName = newWP.oldName;
      delete newWP.oldName;
      var wp = workplanes.find(function(e){return e.name == oldName});
      wp = Object.assign(wp,newWP);
      newWP.oldName = oldName;
      
      this.skp.call_action('edit_workplane',newWP);
    },
    submitEditTask : function(){
      var newTask = this.selectedTask;
      var oldName = newTask.oldName;
      if(oldName){ // editing
        delete newTask.oldName;
        var task = tasks.find(function(e){return e.name == oldName});
        task = Object.assign(task,newTask);  
        newTask.oldName = oldName;    
        this.skp.call_action('edit_task',newTask);
      }else{ // Creating
        tasks.push(newTask);
        this.skp.call_action('add_task',newTask);
      }
    }
  },
  data () {
    return {
      tasks: tasks,
      workplanes: workplanes,
      skp : SKPHelper,
      selectedWorkplane: {},
      selectedTask: {},
      taskProps : taskProperties
    }
  }
}

SKPHelper.call_action('load_workplanes','')
SKPHelper.call_action('load_tasks','')
  
  
</script>
