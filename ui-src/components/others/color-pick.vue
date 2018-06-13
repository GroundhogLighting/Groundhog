<template>


  <div class="a-color-pick" >         
    <i v-bind:style="chosenColor" class='material-icons' v-on:click="showColorSelector = !showColorSelector">
        format_color_fill
    </i>    
    <div class='colours' v-if="showColorSelector">
        <input :value="hsv.h" type='range' min="0" max="360" ref='hue' id='hue' @input="update()">
        <input :value="hsv.s" v-bind:style="saturationRange"  type='range' min="0" max="100" ref='saturation' id='saturation' @input="update()">
        <input :value="hsv.v" v-bind:style="valueRange" min="0" max="100" type='range' ref='val' id='value' @input="update()">   
        <a-flat-button @click.native="showColorSelector = !showColorSelector" :variant="'primary'">Done</a-flat-button>        
    </div>
  </div>

</template>

<script>
export default {
    props: ['value'],            
    data(){
        
        return{            
            showColorSelector: false                              
        }
    },

    methods: {
        update() {
            const color = this.rgbColor();              
            this.$emit('input', {
                r: color[0]/255, g:color[1]/255, b: color[2]/255
            })
        },
        rgbToHSV: function(val){
            
            /* BASED ON https://www.rapidtables.com/convert/color/rgb-to-hsv.html */
            
            const r = val.r;
            const g = val.g;
            const b = val.b;
            const cmax = Math.max(r,g,b);
            const cmin = Math.min(r,g,b);
            const delta = cmax - cmin;

            var h;
            if(delta === 0){
                h = 0;
            }else if(cmax === r){
                h = 60*(((g-b)/delta)%6);
            }else if(cmax === g){
                h = 60*(((b-r)/delta) + 2);
            }else if(cmax === b){
                h = 60*(((r-g)/delta) + 4);
            }

            var s;
            if(cmax === 0){
                s = 0;
            }else{
                s = delta/cmax;
            }

            var v = cmax;

            return {h:Math.round(h),s:Math.round(s*100),v:Math.round(v*100)};

        },
        saturatedColor: function(h){                        
            var r,g,b;
            if(h <= 60){
                r=255;
                g= (255*h/60);
                b=0;
            }else if(h <= 120){
                r = 255-(255*(h-60)/60);
                g= 255;
                b=0;
            }else if(h <= 180){
                r = 0;
                g= 255;
                b= (255*(h-120)/60);
            }else if(h <= 240){
                r = 0;
                g= 255-(255*(h-180)/60);
                b= 255;
            }else if(h <= 300){
                r = (255*(h-240)/60);
                g= 0;
                b= 255;
            }else{
                r = 255;
                g = 0;
                b= 255-(255*(h-300)/60);
            }                    
            return [r,g,b];
        },
        fullyReflectiveColor: function(h,s){
            var saturatedColor =  this.saturatedColor(h);
            var r = saturatedColor[0];
            var g = saturatedColor[1];
            var b = saturatedColor[2];
            var red = 255 - s*(255-r)/100;
            var green = 255 - s*(255-g)/100;
            var blue = 255 - s*(255-b)/100;
            return [red,green,blue];
        },
        rgbColor: function(){              
            var fullyReflectiveColor = this.fullyReflectiveColor(this.$refs.hue.value,this.$refs.saturation.value);            
            return [
                Math.round(fullyReflectiveColor[0]*this.$refs.val.value/100),
                Math.round(fullyReflectiveColor[1]*this.$refs.val.value/100),
                Math.round(fullyReflectiveColor[2]*this.$refs.val.value/100),
            ]
        },
    },
    computed:{        
        saturationRange : function(){
            
            var saturatedColor =  this.saturatedColor(this.hsv.h);
            var res = "";
            res += "background: linear-gradient(to right,rgb(255,255,255),rgb("+saturatedColor.join(',')+"));";            
            return res;
        },
        valueRange: function(){
            
            var fullyReflectiveColor =  this.fullyReflectiveColor(this.hsv.h,this.hsv.s);
            return "background: linear-gradient(to right,rgb(0,0,0),rgb("+fullyReflectiveColor.join(',')+"));";
        },        
        chosenColor: function(){            
            var color = this.value;
            return "border-color: rgb("+Math.round(255*color.r)+','+Math.round(255*color.g)+','+Math.round(255*color.b)+");";
        },
        hsv:function()
        {
            return this.rgbToHSV(this.value);
        }
    },
};
</script>
