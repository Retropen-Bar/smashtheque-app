export const SeeMore = {
  props: {
    "line-clamp": String,
    emptyText: {
      type: String,
      default: "Aucune information disponible",
    },
  },
  data: function () {
    return {
      seeMoreActivated: false,
      collapsedHeight: 0,
      hasSeeMore: false,
    };
  },
  mounted() {
    this.$refs.content.style.setProperty("--line-clamp", this.lineClamp || 10);
    this.$nextTick(function () {
      this.collapsedHeight = this.$refs.content.clientHeight;
    });
  },
  watch: {
    seeMoreActivated: function (val, oldVal) {
      if (val) {
        this.$refs.content.style.maxHeight =
          this.$refs.content.scrollHeight + "px";
      } else {
        this.$refs.content.style.maxHeight = this.collapsedHeight + "px";
      }
    },
    collapsedHeight: function (val) {
      const delta = 1.5 * 16;
      this.hasSeeMore = val < this.$refs.content?.scrollHeight - delta;
    },
  },
  methods: {
    toggleSeeMore() {
      return (this.seeMoreActivated = !this.seeMoreActivated);
    },
  },

  template: `
    <div class="see-more">
      <div :class="{'see-more-content': true, 'collapsed': !seeMoreActivated, 'has-see-more': hasSeeMore}" ref="content" v-if="!!$slots.default && !!$slots.default[0]">
        <slot></slot>
      </div>
      <p v-if="!$slots.default || !$slots.default[0]">{{ emptyText }}</p>
      <div class="text-right" v-if="hasSeeMore">
        <button class="see-more-button btn btn-link px-2 py-1 mr-n2" type="button" @click="toggleSeeMore" v-html="seeMoreActivated ? 'Voir moins' : 'Voir plus'"  />
      </div>
    </div>
  `,
};
