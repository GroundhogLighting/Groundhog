<template>
  <div class="md-color-pick">
    <label >Red</label>     
    <input step="0.01" type="number" ref="red" :value="value.r" @input="update()"/>

    <label for="">Green</label>
    <input step="0.01" type="number" ref="green" :value="value.g" @input="update()"/>
    
    <label for="">Blue</label>
    <input step="0.01" type="number" ref="blue" :value="value.b" @input="update()"/>
    
    <div style="min-width: 20px; min-height: 20px;" v-bind:style="bgc" ref="color"></div>    
  </div>
</template>

<script>
export default {
    props: ['value'],
    
    data(){
        
        return{
            bgc:"background-color: ''"
        }
    },

    methods: {
        update() {
            var r = +this.$refs.red.value;
            var g = this.$refs.green.value;
            var b = this.$refs.blue.value;

            this.bgc="background-color: rgb("+Math.round(255*r)+","+Math.round(255*g)+","+Math.round(255*b)+")";
            console.log(this.bgc);
            this.$emit('input', {
                r: r, g:g, b:b
            })
        }    
    }
};
</script>

<style lang="scss" scoped>
 #color{
     width: 25px;
     height:25px;
 }
</style>
