<template>
  <div id="dialog-outer">
      <div id="dialog-inter" >          
        <div id="dialog-title">
            <!--h2 v-if="title" >{{title}}</h2-->            
            <i @click="$emit('close')" class="material-icons">close</i>            
        </div>

        <div class="dialog-body">
            <slot name="body">
              default body
            </slot>
        </div>

          <div class="dialog-footer">
            <slot name="footer">
              default footer              
            </slot>
          </div>
      </div>
  </div>
</template>
<script>
export default {
  props:['title'],
  data(){
      return {}
  }
}
</script>

<style lang="scss">
    $inter-v-size: 80;
    $inter-h-size: 80;

    @import "../../common/shadows.scss";
    
    #dialog-outer{
        font-family: 'Roboto', sans-serif;
        position:fixed;
        top:0;
        left:0;
        width:100vw;
        height:100vh;
        z-index: 9999999;
        background-color:rgba(0,0,0,0.4);
        font-size: 0.16in;        
    }

    
    #dialog-inter{   
        @include level-5;     
        position:fixed;
        background-color: white;
        //height: #{$inter-v-size}vh;
        //width: #{$inter-h-size}vw;
        color:black;
        top: 0.25in;
        left: 0.5in;
        bottom: 0.25in;
        right: 0.5in;
        padding: 0.25in;
    }

    #dialog-title {
        top:0;
        * {
            display: inline;
        }
        h2{            
            font-size:1.25rem;
            font-weight:500;
            flex:1;            
            letter-spacing:0.02em;
            line-height: 2rem;
            text-align: left;
        }
        i{
            position:absolute;
            right:15px;
            top: 15px;
            cursor:pointer;            
        }
    }
</style>
