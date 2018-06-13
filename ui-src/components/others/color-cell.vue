<template>
    <td >
        <div v-bind:style="bck"></div>
    </td>
</template>

<script>
export default {
    props: ['color'],
    computed: {
        bck: function(){
            return "background-color: rgb("+Math.round(255*this.color.r)+","+Math.round(255*this.color.g)+","+Math.round(255*this.color.b)+")";
        }
    }        
}
</script>

<style lang="scss" scoped>
    $size: 30px;
    div{
        width: $size;
        height: $size;
        border-radius: 50%;
    }
</style>

