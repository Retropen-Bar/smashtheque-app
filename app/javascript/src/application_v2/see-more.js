export const SeeMore = {
  props: ["line-clamp"],
  data: function () {
    return {
      seeMoreActivated: false,
      collapsedHeight: 0,
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
  },
  methods: {
    toggleSeeMore() {
      return (this.seeMoreActivated = !this.seeMoreActivated);
    },
  },

  template: `
    <div class="see-more">
      <div :class="{'see-more-content': true, 'collapsed': !seeMoreActivated}" ref="content">
        <slot></slot>
      </div>
      <div class="text-right">
        <button class="see-more-button btn btn-link" type="button" @click="toggleSeeMore" v-html="seeMoreActivated ? 'Voir moins' : 'Voir plus'"  />
      </div>
    </div>
  `,
};
