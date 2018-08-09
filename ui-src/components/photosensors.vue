<template>
  <div v-container v-with-sidenav>  
    
    <a-navbar fixed variant="primary">   
      <!--i slot="toggle-icon" class="material-icons">menu</i-->     
      
      <a-input :label="'Filter'" v-model="query" :type="'text'"/>
      <a-button :variant="'primary'" v-on:click.native="openDialog">Add photosensor</a-button>      
    </a-navbar>
    

    <span class='no-data' v-show="shownList.length == 0">There are no photosensors to show...</span>  
      
      
      <!-- MATERIALS IN MODEL -->
      <a-table v-show="shownList.length > 0" class="selectable-row">
        <thead>
          <tr>            
            <th>Name</th>
            <th></th>
          </tr>  
        </thead>
        <tbody>
          <tr class="selectable" v-for="m in shownList" :key=m.name >
            <td v-on:click="use(m)">
              {{m.name}}
            </td>            
            <td class="actions">
              <i v-on:click="edit(m.name)" class="material-icons">mode_edit</i>
              <i v-on:click="remove(m.name)" class="material-icons">delete</i>
            </td>
          </tr>
        </tbody>
      </a-table>

    <!-- CREATE MATERIALS DIALOG -->
    <a-dialog @close="onCloseDialog()" :actions="dialogActions" :title="'Photosensor editor'" ref='createDialog'>        
        
          <form>     
            <div id="photosensor_name_dialog">
              <a-input :label="'name'" v-model="selectedPhotosensor.name" type="text"></a-input>
            </div>

            <a-double-entry-table>
              <thead>
                <tr>
                  <td></td>
                  <td>X</td>
                  <td>Y</td>
                  <td>Z</td>
                  
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Position</td>
                  <a-editable-cell v-model="selectedPhotosensor.px"></a-editable-cell>
                  <a-editable-cell v-model="selectedPhotosensor.py"></a-editable-cell>
                  <a-editable-cell v-model="selectedPhotosensor.pz"></a-editable-cell>
                </tr>
                 <tr>
                  <td>Direction</td>
                  <a-editable-cell v-model="selectedPhotosensor.dx"></a-editable-cell>
                  <a-editable-cell v-model="selectedPhotosensor.dy"></a-editable-cell>
                  <a-editable-cell v-model="selectedPhotosensor.dz"></a-editable-cell>
                </tr>
              </tbody>
            </a-double-entry-table>
                    
            
          </form>                  
    </a-dialog>

    <a-toast ref='photosensorUpdated'>Photosensor list updated</a-toast>    
    <a-toast ref='photosensorAdded'>Photosensor added to model</a-toast>    

  </div>
</template>

<style lang="scss" scoped>
  #photosensor_name_dialog{
    
    text-align:center;

    
  }
</style>


<script>

import "~/plugins/init-photosensors";
import SKPHelper from "~/plugins/skp-helper";

export default {
  methods: {
    openDialog(){
      this.skp.call_action("enable_photosensor_tool","");
      this.$refs.createDialog.show(); 
    },
    onCloseDialog(){
      this.selectedPhotosensor = {};
      this.skp.call_action("disable_active_tool","");
    },
    edit(pName){
      var p = photosensors.find(function(m){ return m.name === pName});
      this.selectedPhotosensor = Object.assign({oldName : p.name},p);    
      openDialog();      
    },
    remove(pName){
      var i = photosensors.findIndex(function(m){
          return m.name === pName;
        });        
      if (i > -1) {
        photosensors.splice(i, 1);
      }
      this.skp.call_action('delete_photosensor',pName);
    },
    submitEdit(){

      var newP = this.selectedPhotosensor;
      var oldName = newP.oldName;
      if(oldName){ // editing
        delete newP.oldName;
        var p = photosensors.find(function(e){return e.name == oldName});
        p = Object.assign(p,newP);  
        newP.oldName = oldName;    
        this.skp.call_action('edit_photosensor',newP);
        this.$refs.photosensorUpdated.show();      
      }else{ // Creating
        photosensors.push(newP);
        this.skp.call_action('add_photosensor',newP);
        this.$refs.photosensorAdded.show();      
      }

      this.$refs.createDialog.show();
      
    }  
  },
  computed:{
    shownList: function(){      
      const query = this.query;      
      if(query && query !== ""){                
        return this.photosensors.filter(function(m){
          return m.name.toLowerCase().includes(query);
        });
      }      
      return this.photosensors    
    },
  },
  data: function(){
    return {
      photosensors: photosensors,
      selectedPhotosensor: selected_photosensor,
      query: "",
      dialogActions: { 'Accept' : this.submitEdit },
      skp: SKPHelper,
    };
  }
}

SKPHelper.call_action('load_photosensors','');
</script>
