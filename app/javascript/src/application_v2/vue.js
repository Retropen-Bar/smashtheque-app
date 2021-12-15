import Vue from "vue/dist/vue.common";
import { PalmaresFilters } from "./palmares-filters";
import { SeeMore } from "./see-more";

Vue.config.ignoredElements = ['trix-editor'];

new Vue({
  el: "#app",
  data() {
    return {
      mainNavVisible: false,
      filtersVisible: false,
    };
  },
  components: {
    "palmares-filters": PalmaresFilters,
    "see-more": SeeMore,
  },
});
