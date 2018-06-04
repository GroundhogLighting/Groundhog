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
            return "background-color: rgb("+this.color.r+","+this.color.g+","+this.color.b+")";
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

