<template>
  <div v-container v-with-sidenav> 
    <a-navbar fixed variant="primary">   
      <i slot="toggle-icon" class="material-icons">menu</i>     
      
      <a-input :label="'Filter'" :type="'text'"/>
      <a-button :variant="'primary'" v-on:click.native="$refs.createDialog.show()">Create material</a-button>
    </a-navbar>
    
    
      <!-- NO MATERIALS MESSAGE -->
      <span class='no-data' v-show="!materials || materials.length == 0">There are no materials in your model</span>  
      
      <a-table v-show="materials.length > 0" class="selectable-row">
        <thead>
          <tr>
            <th v-for="h in fields" :key=h.key>{{h.label}}</th>
            <th>Color</th>
            <th></th>
          </tr>  
        </thead>
        <tbody>
          <tr class="selectable" v-for="m in materials" :key=m.name >
            <td v-on:click="use(m.name)" v-for="h in fields" :key=h.key>{{m[h.key]}}</td>
            <color-cell v-on:click.native="use(m.name)" :color="m.color"></color-cell>
            <!--td v-on:click="use(m.name)" v-color-cell=m.color></td-->
            <td class="actions">
              <i v-on:click="edit(m.name)" class="material-icons">mode_edit</i>
              <i v-on:click="remove(m.name)" class="material-icons">delete</i>
            </td>
          </tr>
        </tbody>
      </a-table>

    <a-dialog @close="onCloseDialog()" :actions="dialogActions" :title="'Material editor'" ref='createDialog'>        
        
          <form>        
            <a-input v-model="selectedMaterial.name" :label="'Name'"></a-input>            
            <br>
            <a-select v-model="selectedMaterial.class" :options="Object.keys(materialProps)"></a-select>
            
            <a-hsv-color-pick  v-model="selectedMaterial.color"></a-hsv-color-pick>

            <div v-for="(item, index) in materialProps[selectedMaterial.class]" :key="index"  >
              <a-input 
                :type="'number'" 
                :required="true"                 
                :max="item.max"
                :min="item.min"                
                v-model="selectedMaterial[index]"               
                :label="index">
              </a-input>
              <br>
            </div>
            

            
          </form>        
          
    </a-dialog>
    <a-toast ref='materialUpdated'>Material list updated</a-toast>    
  </div>

  
</template>

<script>


import "~/plugins/init-materials"
import SKPHelper from "~/plugins/skp-helper";
import ColorCell from './others/color-cell'

// Material properties (Color is there by default)
const materialProperties = {
  Plastic : {
    specularity : {default: 0.05, min: 0, max:1},
    roughness: {default: 0.0, min: 0, max:1},
  },
  Metal : {
    specularity: {default: 0.95, min: 0, max:1},
    roughness: {default: 0.0, min: 0, max:1},
  },
  Dielectric : {
    refraction_index : {default: 1.52},
    hartmann_constant: {default: 0}
  }
};


export default {  
  methods : {    
    onCloseDialog(){
      this.selectedMaterial = {
        class: Object.keys(materialProperties)[0],
        color: {r:0.6, g:0.6,b:0.6}
      };
    },
    use(matName){
      this.skp.call_action('use_material',matName);
    },
    edit(matName){
      var mat = materials.find(function(m){ return m.name === matName});
      this.selectedMaterial = Object.assign({oldName : mat.name},mat);    
      this.$refs.createDialog.show();      
    },
    remove(matName){
      var i = materials.findIndex(function(m){
          return m.name === matName;
        });        
      if (i > -1) {
        materials.splice(i, 1);
      }
      this.skp.call_action('delete_material',matName);
    },
    submitEdit(){

      var newMat = this.selectedMaterial;
      var oldName = newMat.oldName;
      if(oldName){ // editing
        delete newMat.oldName;
        var mat = materials.find(function(e){return e.name == oldName});
        mat = Object.assign(mat,newMat);  
        newMat.oldName = oldName;    
        this.skp.call_action('edit_material',JSON.stringify(newMat));
      }else{ // Creating
        materials.push(newMat);
        this.skp.call_action('add_material',JSON.stringify(newMat));
      }

      this.$refs.createDialog.show();
      this.$refs.materialUpdated.show();      
    }
  },
  components : {
    ColorCell : ColorCell
  },
  data () {
    return {
      materials: materials,
      fields : [
          { key: "name", label: "Name"},        
          { key: "class", label: "Class"}
      ],
      skp: SKPHelper,
      selectedMaterial : {
        class: Object.keys(materialProperties)[0],
        color: {r:0.6, g:0.6,b:0.6}
      },
      materialProps : materialProperties,      
      dialogActions: { 'Accept' : this.submitEdit }      
    }
  }
}
  
  
</script>
