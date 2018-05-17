<template>
  <div>
    <a-navbar fixed variant="primary">   
      <i slot="toggle-icon" class="material-icons">menu</i>     
      
      <input  type="text" placeholder="Filter"/>
      <a-button :variant="'primary'" v-on:click.native="showCreateDialog = !showCreateDialog">Create material</a-button>
    </a-navbar>
    
    <div class="view-container"> 
      <!-- NO MATERIALS MESSAGE -->
      <span class="sorry" v-show="!materials || materials.length == 0">There are no materials in your model</span>  
      
      <table v-show="materials.length > 0" class="selectable-row">
        <thead>
          <tr>
            <th v-for="h in fields" :key=h.key>{{h.label}}</th>
            <th>Color</th>
            <th></th>
          </tr>  
        </thead>
        <tbody>
          <tr v-for="m in materials" :key=m.name >
            <td v-on:click="useMaterial(m.name)" v-for="h in fields" :key=h.key>{{m[h.key]}}</td>
            <td v-on:click="useMaterial(m.name)" v-color-cell=m.color></td>
            <td class="actions">
              <i v-on:click="editMaterial(m.name)" class="material-icons">mode_edit</i>
              <i v-on:click="deleteMaterial(m.name)" class="material-icons">delete</i>
            </td>
          </tr>
        </tbody>
      </table>
    </div>


    <a-dialog :actions="dialogActions" :title="'Create a new material'" v-if="showCreateDialog" @close="showCreateDialog = false">        
        
          <form>        
            <a-input v-model="selectedMaterial.name" :label="'Name'"></a-input>
            <a-select v-model="selectedMaterial.class" :options="Object.keys(materialProps)"></a-select>
            
            <a-color-pick v-model="selectedMaterial.color"></a-color-pick>

            <a-input :type="'number'" :step="0.01" v-for="(item, index) in Object.keys(materialProps[selectedMaterial.class])" 
                      :key="index" 
                      v-model="selectedMaterial[item]" :label="Object.keys(materialProps[selectedMaterial.class])[index]"></a-input>

            
          </form>        
    </a-dialog>

  </div>

  
</template>

<script>


import "~/plugins/init-materials"
import SKPHelper from "~/plugins/skp-helper";

// Material properties (Color is there by default)
var materialProperties = {
  Plastic : {
    specularity : 0.05,
    roughness: 0
  },
  Metal : {
    specularity : 0.05,
    roughness: 0
  },
  Dielectric : {
    refraction_index : 1.52,
    hartmann_constant: 0
  }
};


export default {  
  methods : {    
    useMaterial(matName){
      this.skp.call_action('use_material',matName);
    },
    editMaterial(matName){
      this.skp.call_action('edit_material',matName);
    },
    deleteMaterial(matName){
      this.skp.call_action('delete_material',matName);
    },
    createMaterial(){
      console.log("Creating a material!");
    }
  },
  directives : {
    colorCell : {
      inserted: function (el,binding) {
        let color = binding.value;
        let r = color.r;
        let g = color.g;
        let b = color.b;
        el.style.background="rgb("+r+","+g+","+b+")";
      }    
    }
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
      editing: false,
      materialProps : materialProperties,
      showCreateDialog : false,
      dialogActions: {
        'Create material' : function(){
          console.log("Create!");
        }
      }
    }
  }
}
  
  
</script>
