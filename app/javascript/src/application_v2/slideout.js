import Vue from "vue/dist/vue.common";
import Slideout from "@hyjiacan/vue-slideout";

// import Slideout component, and set the defaults props
Vue.use(Slideout);

new Vue({
  el: "#main-nav",
  data() {
    return {
      visible: false,
    };
  },
});

new Vue({
  el: "#index-filters",
  data() {
    return {
      visible: false,
    };
  },
});

