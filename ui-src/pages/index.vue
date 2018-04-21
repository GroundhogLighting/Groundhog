<template>

  <div v-fluid >    
    

          
      <md-sidenav >
        
        <md-sidenav-item v-on:click.native="selectedTab = 'location'" v-selected>
          <i class="material-icons" >location_on</i>
          <span >Location</span>
        </md-sidenav-item>

        <md-sidenav-item v-on:click.native="selectedTab = 'materials'">
          <i class="material-icons" >format_paint</i>
          <span >Materials</span>
        </md-sidenav-item>
        
        <md-sidenav-item v-on:click.native="selectedTab = 'tasks'">
            <i class="material-icons" >brightness_low</i>
            <span >Tasks</span>
        </md-sidenav-item>
        
        <md-sidenav-item v-on:click.native="selectedTab = 'luminaires'">
          <i class="material-icons" >lightbulb_outline</i>
          <span >Luminaires</span>
        </md-sidenav-item>

        <md-sidenav-item v-on:click.native="selectedTab = 'calculate'">
          <i class="material-icons" >play_arrow</i>
          <span >Calculate</span>
        </md-sidenav-item>

        <md-sidenav-item v-on:click.native="selectedTab = 'report'">
          <i class="material-icons" >poll</i>
          <span >Report</span>
        </md-sidenav-item>
        
      </md-sidenav>  
            
      <!--div id="view"-->
     
        <location v-show="selectedTab === 'location'"></location>
        <materials v-show="selectedTab === 'materials'"></materials>
        <tasks v-show="selectedTab === 'tasks'"></tasks>
        <!--luminaires v-show="selectedTab === 'luminaires'"></luminaires>
        <calculate v-show="selectedTab === 'calculate'"></calculate>
        <report v-show="selectedTab === 'report'"></report-->
     
      <!--/div-->        
    
        
  </div>
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
    selectTab: function(){
      console.log('click!');
    }
  },

  data : function(){
    return {
      selectedTab : "location",
      test: {
        a: 1,b:2
      }
    }
  } 
}

</script>

<style lang="scss">
@import "assets/style.scss";


</style>
