<template>
    <div class="v-sidenav-item">
        <slot></slot>
    </div>  
</template>

<style lang="scss" scoped>
    div.v-sidenav-item{
        position: relative;
        box-sizing: border-box;
        display: block;
        padding: 5px;
        cursor: pointer;
        border-radius:2px;
        margin-top:2px;
        margin-bottom:2px;
        height: auto;
        width: 100%;
        display:block;


        *{
            display:block;
            text-align:center;
        }

        i {
            vertical-align: middle; 
            font-size: 0.3in;               
        }
        span{
            font-size: 0.13in;
        }
        
        
    }
</style>
