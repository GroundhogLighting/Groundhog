<template>
  <div>
    <md-navbar fixed variant="primary">        
      <input  type="text" placeholder="Filter"/>
      <a href="#" v-on:click="showCreateDialog = !showCreateDialog">Create material</a>
    </md-navbar>
    
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


    <md-dialog :title="'I am the Title'" v-if="showCreateDialog" @close="showCreateDialog = false">        
        <div slot="body">
          <form>        
            <md-input v-model="selectedMaterial.name" :label="'Name'"></md-input>
            <md-select v-model="selectedMaterial.class" :options="Object.keys(materialProps)"></md-select>
            
            <md-color-pick v-model="selectedMaterial.color"></md-color-pick>

            <md-input :type="'number'" :step="0.01" v-for="(item, index) in Object.keys(materialProps[selectedMaterial.class])" 
                      :key="index" 
                      v-model="selectedMaterial[item]" :label="Object.keys(materialProps[selectedMaterial.class])[index]"></md-input>

            
          </form>
        </div>

        <div slot="footer">
          <md-button :variant="'primary'" @click="showCreateDialog=false">Primary</md-button>
          <md-button :variant="'accent'" @click="showCreateDialog=false">Accent</md-button>
          <md-button :variant="'warn'" @click="showCreateDialog=false">Warn</md-button>
          <md-button :variant="'basic'" @click="showCreateDialog=false">Basic</md-button>
          <md-button :variant="'disabled'" @click="showCreateDialog=false">Disabled</md-button>
          <md-button :variant="'link'" @click="showCreateDialog=false">Link</md-button>

          <md-raised-button :variant="'primary'" @click="showCreateDialog=false">Primary</md-raised-button>
          <md-raised-button :variant="'accent'" @click="showCreateDialog=false">Accent</md-raised-button>
          <md-raised-button :variant="'warn'" @click="showCreateDialog=false">Warn</md-raised-button>
          <md-raised-button :variant="'basic'" @click="showCreateDialog=false">Basic</md-raised-button>
          <md-raised-button :variant="'disabled'" @click="showCreateDialog=false">Disabled</md-raised-button>
          <md-raised-button :variant="'link'" @click="showCreateDialog=false">Link</md-raised-button>

        </div>
    </md-dialog>

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
      showCreateDialog : false
    }
  }
}
  
  
</script>
