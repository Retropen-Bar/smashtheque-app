import Vue from "vue/dist/vue.common";

var vm = new Vue({
  el: "#search",
  data: {
    articleObj: null,
    isResult: false,
    searchQuery: "",
  },
  computed: {},
  ready: function () {},
  methods: {
    removeSearchQuery: function () {
      this.searchQuery = "";
      this.articleObj = null;
      this.isResult = false;
    },
    submitSearch: function () {
      var reqURL = "/api/v1/search?term=" + this.searchQuery;

      fetch(reqURL)
        .then((resp) => resp.json())
        .then((response) => {
          this.articleObj = response.results.reduce(function (
            groups,
            result
          ) {
            var firstType = result.type;
            if (!groups[firstType]) {
              groups[firstType] = [];
            }
            var entry = groups[firstType];
            entry.push(result);

            return groups;
          },
          {});
          this.isResult = Object.keys(this.articleObj).length;
        })
        .catch(function (response) {
          console.log(response);
        });
    },
  },
});

$("#search").on("shown.bs.modal", function () {
  $("#search-input").trigger("focus");
});
