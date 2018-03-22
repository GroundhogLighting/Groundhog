<template>
  <div>
    <b-navbar fixed variant="primary">        
      <input class="sorry" type="text" placeholder="Filter"/>
      <a href="#">Create material</a>
    </b-navbar>
    
    <div class="view-container"> 
      <!-- NO MATERIALS MESSAGE -->
      <span v-show="!materials || materials.length == 0">There are no materials in your model</span>  
      
      <table v-show="materials.length > 0" class="selectable-row">
        <thead>
          <tr>
            <th v-for="h in fields" :key=h>{{h}}</th>
            <th>Color</th>
            <th></th>
          </tr>  
        </thead>
        <tr v-for="m in materials" :key=m.name >
          <td v-on:click="useMaterial(m.name)" v-for="h in fields" :key=h>{{m[h]}}</td>
          <td v-on:click="useMaterial(m.name)" v-color-cell=m.color></td>
          <td class="actions"><i v-on:click="editMaterial(m.name)" class="material-icons">mode_edit</i></td>
        </tr>
      </table>
    </div>

  </div>
</template>

<script>


import "~/plugins/init-materials"

export default {  
  methods : {    
    useMaterial(matName){
      console.log("Using "+matName);
    },
    editMaterial(matName){
      console.log("Editing "+matName);
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
      fields : ["name", "class"]
    }
  }
}
  
  
</script>
