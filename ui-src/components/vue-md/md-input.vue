<template>
  <div class="md-input">
    <input ref="in" type="text" :value="value" required @input="update()">
    <label>{{label}}</label>    
  </div>
</template>

<script>

export default {
  props: ['value','label'],

  methods: {
    toggleOptions(){

    },
    update() {
        this.$emit('input', this.$refs.in.value)
    }
  },
  data(){
      return {
          active : false
      }
  }
};
</script>

<style lang="scss" scoped>
    .md-select{
        .selected{
            background-color: blue;
            color:white;
        }
    }
</style>
