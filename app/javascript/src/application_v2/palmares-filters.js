import Vue from "vue/dist/vue.common";

export const PalmaresFilters = {
  props: ["palmares"],
  data: function () {
    return {
      type: "all",
      orderByDate: null,
      orderByRank: null,
    };
  },
  computed: {
    filteredData() {
      let filteredDataByType = this.palmares;

      if (this.type === "online") {
        filteredDataByType = filteredDataByType.filter(
          (data) => data.is_online
        );
      }

      if (this.type === "offline") {
        filteredDataByType = filteredDataByType.filter(
          (data) => !data.is_online
        );
      }

      if (this.orderByDate === "desc") {
        filteredDataByType.sort((a, b) => new Date(a.date) - new Date(b.date));
      } else {
        filteredDataByType.sort((a, b) => new Date(b.date) - new Date(a.date));
      }

      if (this.orderByRank === "asc") {
        filteredDataByType.sort((a, b) => a.points - b.points);
      } else if (this.orderByRank === "desc") {
        filteredDataByType.sort((a, b) => b.points - a.points);
      }

      return filteredDataByType;
    },
  },
  methods: {
    handleOrderBy(type) {
      const state = this[`orderBy${type}`];

      switch (state) {
        case null:
          this[`orderBy${type}`] = "desc";
          break;
        case "desc":
          this[`orderBy${type}`] = "asc";
          break;
        case "asc":
          this[`orderBy${type}`] = null;
          break;
      }
    },
    handleOrderByDate() {
      this.handleOrderBy("Date");
      this.orderByRank = null;
    },
    handleOrderByRank() {
      this.handleOrderBy("Rank");
      this.orderByDate = null;
    },
  },
};
