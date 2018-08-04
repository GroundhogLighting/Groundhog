<template>
  <div v-container v-with-sidenav> 
    <a-navbar fixed variant="primary">   
      <!--i slot="toggle-icon" class="material-icons">menu</i-->     
      
      <a-input :label="'Filter'" v-model="query" :type="'text'"/>
      <a-button :variant="'primary'" v-on:click.native="$refs.createDialog.show()">Create material</a-button>
      <a-button :variant="'primary'" v-on:click.native="$refs.searchDialog.show()">Search in database</a-button>
    </a-navbar>
    
    
      <!-- NO MATERIALS MESSAGE -->
      <span class='no-data' v-show="shownList.length == 0">There are no materials to show</span>  
      
      <!-- MATERIALS IN MODEL -->
      <a-table v-show="shownList.length > 0" class="selectable-row">
        <thead>
          <tr>
            <th v-for="h in fields" :key=h.key>{{h.label}}</th>
            <th>Color</th>
            <th></th>
          </tr>  
        </thead>
        <tbody>
          <tr class="selectable" v-for="m in shownList" :key=m.name >
            <td v-on:click="use(m)" v-for="h in fields" :key=h.key>{{m[h.key]}}</td>
            <color-cell v-on:click.native="use(m)" :color="m.color"></color-cell>            
            <td class="actions">
              <i v-on:click="edit(m.name)" class="material-icons">mode_edit</i>
              <i v-on:click="remove(m.name)" class="material-icons">delete</i>
            </td>
          </tr>
        </tbody>
      </a-table>

    <!-- CREATE MATERIALS DIALOG -->
    <a-dialog @close="onCloseDialog()" :actions="dialogActions" :title="'Material editor'" ref='createDialog'>        
        
          <form>        
            
            <a-input v-model="selectedMaterial.name" :label="'Name'"></a-input>            
            <br>
            <a-select v-model="selectedMaterial.class" :options="Object.keys(materialProps)"></a-select>
            <br>            
            <div>
              <a-input :min="0" :max="1" :type="'number'" v-model="selectedMaterial.color.r" :label="'Red'" :size="3"></a-input>
              <a-input :min="0" :max="1" :type="'number'" v-model="selectedMaterial.color.g" :label="'Green'" :size="3"></a-input>
              <a-input :min="0" :max="1" :type="'number'" v-model="selectedMaterial.color.b" :label="'Blue'" :size="3"></a-input>
              <div style="width: 25px; height:25px;display:inline-block;border-radius:50%;" v-bind:style="selectedMaterialColor"></div>
              
            </div>

            <div v-for="(item, index) in materialProps[selectedMaterial.class]" :key="index"  >
              <a-input 
                :type="'number'" 
                :required="true"                 
                :max="item.max"
                :min="item.min"                
                v-model="selectedMaterial[index]"               
                :label="index">
              </a-input>              
            </div>            
            
          </form>                  
    </a-dialog>

    <!-- SEARCH MATERIALS DIALOG -->
    <a-dialog :title="'Material database'" ref='searchDialog'>        
      <div id="query-container">
        <a-input id="dbquery" :label="'Filter'" v-model="dbquery"></a-input>        
      </div>
      
      
      <div id="table-container">
        <span v-show="databaseQuery.length == 0" class='no-data' >There are no options matching your search</span>  

        <a-table v-show="databaseQuery.length > 0" class="selectable-row">
          <thead>
            <tr>
              <th v-for="h in fields" :key=h.key>{{h.label}}</th>
              <th>Color</th>
              <th></th>
            </tr>  
          </thead>
          <tbody>
            <tr v-for="m in databaseQuery" :key=m.name >
              <td v-on:click="use(m)" v-for="h in fields" :key=h.key>{{m[h.key]}}</td>
              <color-cell v-on:click.native="use(m)" :color="m.color"></color-cell>            
              <td class="actions">
                <i v-on:click="addMaterialToModel(m)" class="material-icons">get_app</i>
                <i v-on:click="getMaterialInfo(m.url)" class="material-icons">help_outline</i>
              </td>
            </tr>
          </tbody>
        </a-table>

      </div>
    </a-dialog>


    <!-- FEEDBACK -->
    <a-toast ref='materialUpdated'>Material list updated</a-toast>    
    <a-toast ref='materialAdded'>Material added to model</a-toast>    
  </div>

  
</template>

<style lang="scss" scoped>
  .actions{
    i{
      cursor:pointer;
     
    }
  }
</style>


<script>


import "~/plugins/init-materials"
import "~/plugins/materials-lib"
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
    getMaterialInfo(url){
      this.skp.call_action('follow_link',url);
    },
    addMaterialToModel(material){
      var newMat = JSON.parse(JSON.stringify(material))
      if(this.materials.find(function(m){ return m.name === newMat.name }) == undefined){
        this.materials.push(newMat);
        this.skp.call_action('add_material',newMat);
      }
      this.$refs.searchDialog.show();      
      this.$refs.materialAdded.show();      
    },
    onCloseDialog(){
      this.selectedMaterial = {
        class: Object.keys(materialProperties)[0],
        color: {r:0.6, g:0.6,b:0.6}
      };
    },
    use(mat){      
      this.skp.call_action('use_material',mat);
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
        this.skp.call_action('edit_material',newMat);
      }else{ // Creating
        materials.push(newMat);
        this.skp.call_action('add_material',newMat);
      }

      this.$refs.createDialog.show();
      this.$refs.materialUpdated.show();      
    }  
  },
  components : {
    ColorCell : ColorCell
  },
  computed: {
    selectedMaterialColor: function(){
      var ret = "background-color: rgb(";
      ret = ret+ Math.round(255*this.selectedMaterial.color.r)+",";
      ret = ret+Math.round(255*this.selectedMaterial.color.g)+",";
      ret = ret+Math.round(255*this.selectedMaterial.color.b);
      ret = ret+")";
      return ret;
    },
    shownList: function(){      
      const query = this.query;      
      if(query && query !== ""){                
        return this.materials.filter(function(m){
          return (m.name.toLowerCase().includes(query) || m.class.toLowerCase().includes(query))
        });
      }      
      return this.materials    
    },
    databaseQuery: function(){
      const dbquery = this.dbquery; 
      if(dbquery && dbquery !== ""){                
        return this.database.filter(function(m){
          return (m.name.toLowerCase().includes(dbquery) || m.class.toLowerCase().includes(dbquery))
        });
      }                 
      return this.database
    }
  },
  data () {
    return {
      query: "",
      dbquery : "",
      materials: materials,
      database : material_lib,
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

SKPHelper.call_action('load_materials','');
  
</script>
