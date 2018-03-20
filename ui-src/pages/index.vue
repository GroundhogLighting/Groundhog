<template>
<div>

    <b-navbar fixed variant="primary">
        <a href="#">Get weather data</a>
    </b-navbar>

  <div class="view-container">  

    <table>
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
        <td><input v-on:change="updateLocation()" v-model="location.time_zone" type="text" v-editable size="15"></td>
      </tr>
      <tr>
        <td>Albedo (%)</td>
        <td><input v-on:change="updateLocation()" v-model="location.albedo" type="text" v-editable size="15"></td>
      </tr>
    </table>
    
  </div>
</div>
</template>

<script>
import "~/plugins/init-location";
import EditableInput from "~/components/editable-input";

export default {
  
  directives : {
    editable : EditableInput
  },
  methods : {
    updateLocation(){
      console.log("Updating location!");
    }
  },

  data(){
    return{
      location: project_location
    }
  }

}
</script>

