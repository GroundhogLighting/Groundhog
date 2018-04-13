<template>
  <div class="md-select">
    <div @click="active = true" class="selected" style="cursor:pointer;">
        <span ref="s">Select an option...</span>
        <i style="font-size:150%;float:right;display:inline;" class="material-icons">arrow_drop_down</i>
    </div>
    <div class="items" v-if="active">
        <div v-for="(o, index) in options" :key="index" @click="chooseOption(o)">{{o}}</div>     
    </div>
  </div>
</template>

<script>

export default {
  props: ['value','options'],

  methods: {
    chooseOption(optionName){
        this.$refs.s.innerHTML = optionName;
        this.$emit('input', optionName);
        this.active = false;
    }
  },
  data(){
      return {
          active : false
      }
  }
};
</script>
