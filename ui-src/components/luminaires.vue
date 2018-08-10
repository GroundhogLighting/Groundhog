<template>
  <div v-container v-with-sidenav>  
    
    
    <a-navbar fixed variant="primary">         
      <a-input :label="'Filter'" v-model="query" :type="'text'"/>      
    </a-navbar>
    
    <span class='no-data' v-show="shownList.length == 0">There are no luminaires to show...</span>  
      
    <a-table v-show="shownList.length != 0">
      <thead>
        <tr>
          <td>Name</td>
          <td>Manufacturer</td>
          <td>Lamp</td>
          <td></td>
        </tr>
      </thead>
      <tbody>
        <tr class="selectable" v-for="m in shownList" :key=m.name >
          <td v-on:click="use(m.name)">{{m.name}}</td>
          <td v-on:click="use(m.name)">{{m.manufacturer}}</td>
          <td v-on:click="use(m.name)">{{m.lamp}}</td>
          <td class="actions">
              <i v-on:click="edit(m.name)" class="material-icons">mode_edit</i>
              <i v-on:click="remove(m.name)" class="material-icons">delete</i>
            </td>
        </tr>
      </tbody>
    </a-table>
      
  </div>
</template>


<script>

import "~/plugins/init-luminaires";
import SKPHelper from "~/plugins/skp-helper";

export default {
  methods: {
    use: function(luminaireName){
      this.skp.call_action("use_luminaire",luminaireName);
    }
  },
  computed: {
    shownList: function(){
      const query = this.query;      
      if(query && query !== ""){                
        return this.luminaires.filter(function(m){
          return (  
            m.name.toLowerCase().includes(query) || 
            m.manufacturer.toLowerCase().includes(query) ||
            m.lamp.toLowerCase().includes(query)
          );
        });
      }      
      return this.luminaires  
    }
  },
  data: function(){
    return{
      luminaires : luminaires,
      query: "",
      skp: SKPHelper
    }
  }
}

SKPHelper.call_action("load_luminaires",'');
</script>
