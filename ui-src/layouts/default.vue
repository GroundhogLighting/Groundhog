<template>
  <b-container fluid >
    <b-row>
      <div>        
        

        <div id="sidebar" >
          <div>
            <nuxt-link to="/">
              <i class="material-icons" >location_on</i>
              <span class="d-none d-sm-inline">Location</span>
            </nuxt-link>
            <nuxt-link to="/materials">
              <i class="material-icons" >format_paint</i>
              <span class="d-none d-sm-inline">Materials</span>
            </nuxt-link>
            <nuxt-link to="/tasks">
              <i class="material-icons" >brightness_low</i>
              <span class="d-none d-sm-inline">Tasks</span>
            </nuxt-link>
            <nuxt-link to="/luminaires">
              <i class="material-icons" >lightbulb_outline</i>
              <span class="d-none d-sm-inline">Luminaires</span>
            </nuxt-link>
            <nuxt-link to="/calculate">
              <i class="material-icons" >play_arrow</i>
              <span class="d-none d-sm-inline">Calculate</span>
            </nuxt-link>
            <nuxt-link to="/report">
              <i class="material-icons" >poll</i>
              <span class="d-none d-sm-inline">Report</span>
            </nuxt-link>
          </div>
        </div>
      </div>
      
      
      <div id="view">
        <nuxt/>
      </div>
    </b-row>
    
        
  </b-container>
</template>


<style lang="scss">

@import "assets/style.scss";

</style>
