<template>
<div v-container v-with-sidenav> 

    <a-navbar fixed variant="primary">
      <a-button :variant="'primary'" v-on:click.native="skp.call_action('set_weather_file','')">Set weather file</a-button>
      <a-button :variant="'primary'" v-on:click.native="skp.call_action('follow_link','http://www.energyplus.net/weather')">Find more weather files</a-button>      
    </a-navbar>


    <a-double-entry-table>
      <thead>

      </thead>
      <tbody>

      <tr>
        <td>Country</td>        
        <a-editable-cell @submit="updateLocation()" v-model="location.country"></a-editable-cell>        
      </tr>
      <tr>
        <td>City</td>        
        <a-editable-cell @submit="updateLocation()" v-model="location.city"></a-editable-cell>        
      </tr>
      <tr>
        <td>Latitude</td>        
        <a-editable-cell @submit="updateLocation()" v-model="location.latitude"></a-editable-cell>        
      </tr>
      <tr>
        <td>Longitude</td>        
        <a-editable-cell @submit="updateLocation()" v-model="location.longitude"></a-editable-cell>
      </tr>
      <tr>
        <td>Time Zone (GMT)</td>
        <a-editable-cell @submit="updateLocation()" v-model="location.timezone"></a-editable-cell>
      </tr>
      <tr>
        <td>Albedo (%)</td>        
        <a-editable-cell @submit="updateLocation()" v-model="location.albedo"></a-editable-cell>                
      </tr>
      </tbody>
    </a-double-entry-table>
    
  
</div>
</template>

<script>
import "~/plugins/init-location";
import EditableInput from "./editable-input";
import SKPHelper from "~/plugins/skp-helper";

export default {
  
  directives : {
    editable : EditableInput
  },
  methods : {
    updateLocation(){      
      this.skp.call_action('update_model_location','');
    },
    
  },
  data(){
    return{
      test: false,
      location: project_location,
      skp: SKPHelper
    }
  }

}
</script>

