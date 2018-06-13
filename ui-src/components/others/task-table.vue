<template>
    <a-double-entry-table>
        <thead>
            <tr>
                <td></td>
                <td v-for="(wp,wpIndex) in workplanes" v-bind:key="wpIndex">
                    {{wp.name | limitString(7)}}
                    
                    <i v-on:click="editWP(wp.name)" class="material-icons action">edit</i>
                    <i v-on:click="removeWP(wp.name)"  class="material-icons action">delete</i>                  
                </td>
            </tr>
        </thead>
        <tbody>
            <tr v-for="(task,taskIndex) in tasks" v-bind:key="taskIndex">
                <td>
                    {{task.name | limitString(7)}}  
                    <i v-on:click="editTask(task.name)"  class="material-icons action">edit</i>
                    <i v-on:click="removeTask(task.name)"  class="material-icons action">delete</i>                  
                </td>
                <td 
                    v-for="(wp,wpIndex) in workplanes" v-bind:key="wpIndex"
                    v-on:click="check(task.name,wp.name)" 
                    class="selectable check-cell" 
                >

                    <i v-if="isChecked(task.name,wp.name)" class="material-icons">check</i>
                </td>
            </tr>
        </tbody>
    </a-double-entry-table>
</template>
<script>


export default {
    methods:{
        isChecked : function(task,wp){               
            var workplane = workplanes.find(function(o){ return o.name === wp})                        
            return  workplane.tasks.includes(task);
        },
        check: function(taskName,wpName){                                     
            var workplane = workplanes.find(function(wp){return wp.name === wpName});

            if(workplane.tasks.includes(taskName)){
                var i = workplane.tasks.indexOf(taskName);
                workplane.tasks.splice(i,1);
            }else{
                workplane.tasks.push(taskName);
            }

            // Inform main UI
            this.$emit('check',taskName,wpName);    
        },
        removeTask: function(taskName){            
            // Remve from all workplanes
            workplanes.forEach(function(wp){
                if(wp.tasks.includes(taskName)){
                    var i = wp.tasks.indexOf(taskName);
                    wp.tasks.splice(i,1);
                }
            })
            // Remove from the list
            var index;
            tasks.find(function(t,i){index = i; return t.name === taskName});
            tasks.splice(index,1);

            // Inform main UI
            this.$emit('removeTask',taskName);
        },
        removeWP: function(wpName){ 
            
            var i = workplanes.findIndex(function(wp){return wp.name === wpName});
            workplanes.splice(i,1);  
            
            // Inform main UI
            this.$emit('removeWP',wpName);        
        },
        editTask: function(taskName){
            // Inform main UI
            this.$emit('editTask',taskName);
        },
        editWP: function(wpName){
            // Inform main UI
            this.$emit('editWP',wpName);
        }
    },
    computed:{
           
    },
    props:[
        'workplanes','tasks'
    ]        
}
</script>

