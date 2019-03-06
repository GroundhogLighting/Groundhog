<template>
  <div v-container v-with-sidenav>  
    <a-navbar fixed variant="primary">              
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
          <div style="text-align:center">              
            <a-input :label="'Name'" v-model="selectedTask.name"></a-input>
            <br>
            <a-select v-model="selectedTask.class" :options="Object.keys(taskProps)"></a-select>
            <br>
          </div>
          <a-double-entry-table>
            <thead>
            </thead>
            <tbody>
              <tr v-for="(item, index) in taskProps[selectedTask.class]" :key="index">
                <td>{{index | fixString}}</td>
                <a-editable-cell :type="'number'" v-model="selectedTask[index]"></a-editable-cell>
              </tr>
            </tbody>
          </a-double-entry-table>           
          
        </form>
      </a-dialog>

      <!-- EDIT WORKPLANE DIALOG -->
      <a-dialog :actions="{'Accept' : submitEditWorkplane}" ref='workplaneEditor' :title="'Workplane editor'"  @close="selectedWorkplane = {}">        
        <form>
          <div style="text-align:center">              
            <a-input :label="'Name'" v-model="selectedWorkplane.name"></a-input>
          </div>
          
          <a-double-entry-table>
            <thead>

            </thead>
            <tbody>
              <tr>
                <td>Pixel Size</td>
                <a-editable-cell  :type="'number'" v-model="selectedWorkplane.pixel_size"></a-editable-cell>
              </tr>
            </tbody>
          </a-double-entry-table>
          
        </form>
      </a-dialog>

  </div>
</template>

<script>


import "~/plugins/init-tasks";
import SKPHelper from "~/plugins/skp-helper";
import TaskTable from "./others/task-table";

const taskProperties = {
  "Useful Daylight Illuminance" : {
    min_lux : {default: 300, min: 0},
    max_lux : {default: 3000, min: 0},
    early : {default: 8, min: 0, max: 24},
    late : {default: 18, min: 0, max: 24},
    first_month : {default: 0, min: 1, max: 12},
    last_month : {default: 12, min: 1, max: 12},
    expected_time: {default: 50, min: 0, max: 100}
  },
  "Daylight Autonomy" : {
    min_lux : {default: 300, min: 0},
    early : {default: 8, min: 0, max: 24},
    late : {default: 18, min: 0, max: 24},
    first_month : {default: 0, min: 1, max: 12},
    last_month : {default: 12, min: 1, max: 12},
    expected_time: {default: 50, min: 0, max: 100}
  },
  "Daylight Factor": {
    min_percent: {default: 3, min: 0, max: 100},
    max_percent: {default: 3, min: 0, max: 100}
  },
  "Annual solar irradiation": {
    min_energy: {},
    max_energy: {}
  },
  "Annual daylight exposure": {
    min_lux_hours: {},
    max_lux_hours: {}
  },
  "Clear sky illuminance" : {
    month: {default: 1, min: 1, max: 12},
    day: {default: 1, min: 1, max: 31},
    hour: {default: 14, min: 1, max: 24},
    min_lux: {default: 3, min: 0, max: 100},
    max_lux: {default: 3, min: 0, max: 100}
  },
  "Intermediate sky illuminance" : {
    month: {default: 1, min: 1, max: 12},
    day: {default: 1, min: 1, max: 31},
    hour: {default: 14, min: 1, max: 24},
    min_lux: {default: 3, min: 0, max: 100},
    max_lux: {default: 3, min: 0, max: 100}
  },
  "Overcast sky illuminance" : {
    month: {default: 1, min: 1, max: 12},
    day: {default: 1, min: 1, max: 31},
    hour: {default: 14, min: 1, max: 24},
    min_lux: {default: 3, min: 0, max: 100},
    max_lux: {default: 3, min: 0, max: 100}
  },
  "Weather sky illuminance" : {
    month: {default: 1, min: 1, max: 12},
    day: {default: 1, min: 1, max: 31},
    hour: {default: 14, min: 1, max: 24},
    min_lux: {default: 3, min: 0, max: 100},
    max_lux: {default: 3, min: 0, max: 100}
  },
  "Annual Sunlight Exposure" : {
    min_lux : {default: 300, min: 0},
    early : {default: 8, min: 0, max: 24},
    late : {default: 18, min: 0, max: 24},
    first_month : {default: 0, min: 1, max: 12},
    last_month : {default: 12, min: 1, max: 12},
    expected_time: {default: 50, min: 0, max: 100}
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
