<template>
  <div>
    <b-navbar fixed variant="primary">        
      <input class="sorry" type="text" placeholder="Filter"/>
      <a href="#" v-b-modal.material-editor>Create material</a>
    </b-navbar>
    
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


    <b-modal id="material-editor" title="">

      <form>        
          <md-input v-model="selectedMaterial.name" :label="'Name'"></md-input>
          <md-select v-model="selectedMaterial.class" :options="Object.keys(materialProps)"></md-select>
          
          <md-color-pick v-model="selectedMaterial.color"></md-color-pick>

          <md-input v-for="(item, index) in Object.keys(materialProps[selectedMaterial.class])" 
                    :key="index" 
                    v-model="selectedMaterial[item]" :label="Object.keys(materialProps[selectedMaterial.class])[index]"></md-input>

          
      </form>
    </b-modal>


  </div>

  
</template>

<script>


import "~/plugins/init-materials"
import SKPHelper from "~/plugins/skp-helper";
import MdSelect from "./vue-md/md-select";
import MdInput from "./vue-md/md-input";
import MdColorPick from "./vue-md/md-color-pick";

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
  components :{
    MdSelect,
    MdInput,
    MdColorPick
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
      materialProps : materialProperties
    }
  }
}
  
  
</script>
