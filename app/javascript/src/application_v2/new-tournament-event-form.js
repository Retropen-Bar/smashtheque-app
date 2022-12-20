export const NewTournamentEventForm = {
  mounted() {
    this.toggleCustomBracketDetails();
    this.$el.addEventListener('input', (e) => {
      this.toggleCustomBracketDetails();
    });
  },
  methods: {
    toggleCustomBracketDetails() {
      $(this.$el.querySelector('.custom-bracket-details')).toggle(this.shouldDisplayCustomBracketDetails());
    },

    shouldDisplayCustomBracketDetails() {
      let bracketUrl = this.$el.elements['tournament_event[bracket_url]'].value;
      if(!bracketUrl) return false;
      if(!(bracketUrl.startsWith('https://') || bracketUrl.startsWith('http://'))) bracketUrl = `https://${bracketUrl}`;

      try {
        const url = new URL(bracketUrl);
        return !['start.gg', 'www.start.gg', 'challonge.com', 'www.challonge.com'].includes(url.host);
      } catch (exceptionVar) {
        // parsing URL failed
        return false;
      }
    }
  }
};
