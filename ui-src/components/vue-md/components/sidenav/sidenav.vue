<template>
  <div class="v-sidenav" v-select>      
    <slot></slot>
  </div>
</template>

<script>
export default {  
    directives:{
        
        select : {
            inserted: function(el){
                var children = el.children;
                
                // Handle the OnClick event
                for(var i=0; i<children.length; i++){                                
                    // Unselect all elements, except with the one clicked                
                    
                    children[i].onclick=function(){                                        
                        
                        for(var j=0; j<children.length; j++){
                            children[j].classList.remove("v-selected");
                        }
                        this.classList.add("v-selected");
                    }// end of OnClick function
                    
                }
            }
        }
    },
    data(){
        return {

        }
    }
}
</script>


<style lang="scss" scoped>

div{    
    z-index:9999;
    width: auto;
    margin-top:auto;
    margin-bottom:auto;
    position: fixed;
    left:0;
    top: 50%;
    //left: 50%;
    transform: translate(0, -50%);
}

</style>
