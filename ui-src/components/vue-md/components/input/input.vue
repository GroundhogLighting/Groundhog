<template>
  <div class="md-input">
    <input ref="in" :type="type || 'text'" :step="step" :value="value" required @input="update()">
    <label>{{label | FixString}}</label>    
  </div>
</template>

<script>
import FixString from "../../filters/fix-string";

export default {
    props: ['value','label','type','step'],
    filters : {
        FixString : FixString
    },
    methods: {
        update() {
            var input = this.$refs.in;
            console.log(input.value);
            console.log(input.checkValidity())
            this.$emit('input', input.value)
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
