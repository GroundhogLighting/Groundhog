<template>
  <nav class="navbar">
      <div>
        <slot></slot>
      </div>
  </nav>
</template>

<style lang="scss" scoped>
nav{
    position: absolute;
    left:0;
    right:0;
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    -ms-flex-wrap: wrap;
    flex-wrap: wrap;
    -webkit-box-align: center;
    -ms-flex-align: center;
    align-items: center;
    -webkit-box-pack: justify;
    -ms-flex-pack: justify;        
    //padding: 0.5rem 1rem;
    align-content: flex-end;
    text-align:right;    
}
div{
    float:right;
    width:100%;
}
</style>

