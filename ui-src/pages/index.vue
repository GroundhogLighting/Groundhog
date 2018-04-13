<template>

  <b-container fluid >
    <b-row>
      
      <div id="sidebar" >
        <ul>
          <li v-bind:class="{ selected: selectedTab === 'location' }" v-on:click="selectedTab = 'location'" >
            <i class="material-icons" >location_on</i>
            <span class="d-none d-sm-inline">Location</span>
          </li>
          <li v-bind:class="{ selected: selectedTab === 'materials' }" v-on:click="selectedTab='materials'">
            <i class="material-icons" >format_paint</i>
            <span class="d-none d-sm-inline">Materials</span>
          </li>
          <li v-bind:class="{ selected: selectedTab === 'tasks' }" v-on:click="selectedTab='tasks'">
            <i class="material-icons" >brightness_low</i>
            <span class="d-none d-sm-inline">Tasks</span>
          </li>
          <li v-bind:class="{ selected: selectedTab === 'luminaires' }" v-on:click="selectedTab='luminaires'">
            <i class="material-icons" >lightbulb_outline</i>
            <span class="d-none d-sm-inline">Luminaires</span>
          </li>
          <li v-bind:class="{ selected: selectedTab === 'calculate' }" v-on:click="selectedTab='calculate'">
            <i class="material-icons" >play_arrow</i>
            <span class="d-none d-sm-inline">Calculate</span>
          </li>
          <li v-bind:class="{ selected: selectedTab === 'report' }" v-on:click="selectedTab='report'">
            <i class="material-icons" >poll</i>
            <span class="d-none d-sm-inline">Report</span>
          </li>
        </ul>
      </div>      
      
            
      <div id="view">
     
        <location v-show="selectedTab === 'location'"></location>
        <materials v-show="selectedTab === 'materials'"></materials>
        <tasks v-show="selectedTab === 'tasks'"></tasks>
        <!--luminaires v-show="selectedTab === 'luminaires'"></luminaires>
        <calculate v-show="selectedTab === 'calculate'"></calculate>
        <report v-show="selectedTab === 'report'"></report-->
     
      </div>
    </b-row>
    
        
  </b-container>
</template>

<script>

import Location from "~/components/location"
import Materials from "~/components/materials"
import Tasks from "~/components/tasks"
import Luminaires from "~/components/luminaires"
import Calculate from "~/components/calculate"
import Report from "~/components/report"


export default {
  components : {
    Location : Location,
    Materials : Materials,
    Tasks : Tasks,
    Luminaires : Luminaires,
    Calculate : Calculate,
    Report : Report
  },
  methods : {
    
  },

  data : function(){
    return {
      selectedTab : "location"
    }
  } 
}

</script>

<style lang="scss">
@import "assets/style.scss";


</style>
