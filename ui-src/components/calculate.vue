<template>
  <div v-container v-with-sidenav> 
    
    
    
    <a-button v-on:click.native="setLowOptions()" :variant="'primary'">Set options to Low</a-button>        
    <a-button v-on:click.native="setMediumOptions()" :variant="'primary'">Set options to Medium</a-button>
    <a-button v-on:click.native="setHighOptions()" :variant="'primary'">Set options to High</a-button>     
    <a-button :variant="'primary'" v-on:click.native="$refs.advancedOptions.show()">Advanced</a-button>    

  <br><br>      
  
    <a-raised-button :variant="'primary'" v-on:click.native="skp.call_action('run_emp','solve_model')">
      <i class="material-icons">play_circle_outline</i>      
      <span>Calculate model</span>
    </a-raised-button>
    
    

    <a-dialog ref='advancedOptions' :title="'Advanced Radiance options'" >              
      <div id="query-container">
        <a-input id="query" :label="'Filter'" v-model="query"></a-input>        
      </div>
      
      
      <div id="table-container">
        <span v-show="toShow.length == 0" class='no-data' >There are no options matching your search</span>  

        <a-table v-show="toShow.length != 0">
          <thead>
            <tr>
              <td>Option name</td><td>Code</td><td>Value</td>
            </tr>        
          </thead>
          <tbody>
            <tr v-for="(option, index) in toShow" :key="index"  >
              <td>{{option.name}}</td>
              <td>{{option.id}}</td>
              <a-editable-cell v-model="option.value" @submitCell="setOption(option.name)"></a-editable-cell>
            </tr>
          </tbody>
        </a-table>
      </div>
      
    
      
    </a-dialog>

    <a-toast ref="theToast">
      {{modifiedOption}}
    </a-toast>

    <a-toast ref="lowToast">
      Options set to low
    </a-toast>
    <a-toast ref="mediumToast">
      Options set to medium
    </a-toast>
    <a-toast ref="highToast">
      Options set to high
    </a-toast>

  </div>
</template>

<style lang="scss" scoped>

#query-container {
  text-align:center;
}

#table-container{
  text-align: center;
}

h3{
  text-align: left;
  padding-left: 40px;
}
#options-field{
  //background-color: red;  
}
</style>


<script>

import SKPHelper from "~/plugins/skp-helper";

const low_options = [
  { name : "Ambient bounces", id : "ab", value: 2 },
  { name : "Ambient divitions", id : "ad", value: 1024 },
  { name : "Limit weight", id : "lw", value: 2e-3 },
]

const medium_options = [
  { name : "Ambient bounces", id : "ab", value: 4 },
  { name : "Ambient divitions", id : "ad", value: 2048 },
  { name : "Limit weight", id : "lw", value: 1e-4 },
]
const high_options = [
  { name : "Ambient bounces", id : "ab", value: 7 },
  { name : "Ambient divitions", id : "ad", value: 5000 },
  { name : "Limit weight", id : "lw", value: 1e-5 },
]

const default_options = [
  // AMBIENT
  { name : "Ambient accuracy", id : "aa", value: 0.1 },
  { name : "Ambient bounces", id : "ab", value: 0 },
  { name : "Ambient divitions", id : "ad", value: 1024 },
  { name : "Ambient resolution", id : "ar", value: 256 },
  { name : "Ambient supersamples", id : "as", value: 512 },
  { name : "Ambient value weight", id : "aw", value: 0 },  

  // DIRECT
  { name : "Direct certainty", id : "dc", value: 0.75 },
  { name : "Direct jitter", id : "dj", value: 0.0 },
  { name : "Direct threshold", id : "dt", value: 0.03 },
  { name : "Direct pretest density", id : "dp", value: 512 },
  { name : "Direct relays", id : "dr", value: 2 },
  { name : "Direct sampling", id : "ds", value: 0.2 },

  // LIMIT
  { name : "Limit reflection", id : "lr", value: -10 },
  { name : "Limit weight", id : "lw", value: 2e-3 },

  { name : "Mist sampling distance", id : "ms", value: 0 },	
  { name : "Mist scattering eccentricity", id : "mg", value: 0.0 },

  // SPECULAR
  { name : "Specular sampling", id : "ss", value: 1.0 },
  { name : "Specular threshold", id : "st", value: 0.15 },  
]

// Default project_options will be the default
var project_options = JSON.parse(JSON.stringify(default_options));

export default {
  methods : {
    setOption : function(optName){
      
      const option = this.options.find(o => o.name === optName);
      this.skp.call_action("set_option",{name: optName,value:option.value});
      this.modifiedOption = optName + ' set to '+option.value;
      this.$refs.theToast.show();
    },
    setSeveralOptions : function(opts){          
      
      // Change the options passed
      this.options.forEach(function(option,i){
        const optionName = option.name;                
        const newOption = opts.find(o => o.name === optionName);
        if(newOption === undefined){
          // option is not passed... set default
          option.value = default_options.find( o=> o.name === optionName).value;
        }else{
          // Option was passed
          option.value = newOption.value;
        }
      });
      this.skp.call_action("set_various_options",this.options);
        
    },
    setLowOptions : function(){      
      this.setSeveralOptions(low_options);
      this.$refs.lowToast.show();
    },
    setMediumOptions : function(){
      this.setSeveralOptions(medium_options);
      this.$refs.mediumToast.show();
    },
    setHighOptions : function(){
      this.setSeveralOptions(high_options);
      this.$refs.highToast.show();
    }

  },
  computed : {
    toShow : function(){
      const query = this.query.toLowerCase();
      if(query === ""){
        return this.options;
      }else{
        return this.options.filter( opt =>  opt.name.toLowerCase().includes(query) || opt.id.toLowerCase().includes(query) )
      }
    }
  },
  data : function(){
    return{
      query: "",
      options : project_options,
      skp: SKPHelper,
      modifiedOption: 'anOption'

    }
  }
}

//SKPHelper.call_action("load_options",'');
</script>
