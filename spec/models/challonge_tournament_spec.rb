require 'rails_helper'

RSpec.describe ChallongeTournament, type: :model do

  context 'helpers' do
    describe '.slug_from_url' do
      it 'with perfect URL' do
        expect(ChallongeTournament.slug_from_url('https://challonge.com/fr/toto')).to eq('toto')
      end

      it 'with URL too long' do
        expect(ChallongeTournament.slug_from_url('https://challonge.com/fr/toto/standings')).to eq('toto')
      end

      it 'with nil' do
        expect(ChallongeTournament.slug_from_url(nil)).to eq(nil)
      end

      it 'with empty URL' do
        expect(ChallongeTournament.slug_from_url('')).to eq('')
      end

      it 'with bad URL' do
        expect(ChallongeTournament.slug_from_url('https://challonge.com/fr/')).to eq('')
      end
    end
  end

end
