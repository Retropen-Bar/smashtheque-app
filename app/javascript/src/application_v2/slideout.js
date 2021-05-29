import Vue from "vue/dist/vue.common";
import Slideout from "@hyjiacan/vue-slideout";
import "@hyjiacan/vue-slideout/lib/slideout.css";

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
