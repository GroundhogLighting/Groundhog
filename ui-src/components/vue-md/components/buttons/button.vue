<template>

    <button class="flat" v-bind:class="variant">   
        <slot>Flat Button Text</slot>        
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
