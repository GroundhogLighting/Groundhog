<template>

    <button class="raised" v-bind:class="variant">   
        <slot>Raised Button Text</slot>        
    </button>
</template>


<script>
export default {
    props: ['variant'],    
}
</script>

<style lang="scss" scoped>

span {
    cursor: pointer;
}



</style>
