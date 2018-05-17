<template>
<div>

    <a-navbar fixed variant="primary">
      <a-button :variant="'primary'" v-on:click.native="skp.call_action('set_weather_file','')">Set weather file</a-button>
      <a-button :variant="'primary'" v-on:click.native="skp.call_action('follow_link','http://www.energyplus.net/weather')">Find more weather files</a-button>      
    </a-navbar>

  <div class="view-container">  
    <table>
      <tbody>

      <tr>
        <td>Country</td>
        <td><input v-on:change="updateLocation()" v-model="location.country" type="text" v-editable size="15"></td>
      </tr>
      <tr>
        <td>City</td>
        <td><input v-on:change="updateLocation()" v-model="location.city" type="text" v-editable size="15"></td>
      </tr>
      <tr>
        <td>Latitude</td>
        <td><input v-on:change="updateLocation()" v-model="location.latitude" type="text" v-editable size="15"></td>
      </tr>
      <tr>
        <td>Longitude</td>
        <td><input v-on:change="updateLocation()" v-model="location.longitude" type="text" v-editable size="15"></td>
      </tr>
      <tr>
        <td>Time Zone (GMT)</td>
        <td><input v-on:change="updateLocation()" v-model="location.timezone" type="text" v-editable size="15"></td>
      </tr>
      <tr>
        <td>Albedo (%)</td>
        <td><input v-on:change="updateLocation()" v-model="location.albedo" type="text" v-editable size="15"></td>
      </tr>
      </tbody>
    </table>
    
  </div>
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
      location: project_location,
      skp: SKPHelper
    }
  }

}
</script>

