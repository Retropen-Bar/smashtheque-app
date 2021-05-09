require 'rails_helper'

RSpec.describe BraacketTournament, type: :model do

  context 'helpers' do
    describe '.slug_from_url' do
      it 'with perfect URL' do
        expect(BraacketTournament.slug_from_url('https://braacket.com/tournament/foo')).to eq('foo')
      end

      it 'with URL a bit too long' do
        expect(BraacketTournament.slug_from_url('https://braacket.com/tournament/foo/')).to eq('foo')
      end

      it 'with URL too long' do
        expect(BraacketTournament.slug_from_url('https://braacket.com/tournament/foo/ranks')).to eq('foo')
      end

      it 'with only slug' do
        expect(BraacketTournament.slug_from_url('foo')).to eq('foo')
      end

      it 'with nil' do
        expect(BraacketTournament.slug_from_url(nil)).to eq(nil)
      end

      it 'with empty URL' do
        expect(BraacketTournament.slug_from_url('')).to eq(nil)
      end

      it 'with bad URL' do
        expect(BraacketTournament.slug_from_url('https://braacket.com/tournament/')).to eq(nil)
      end

      it 'with bad URL' do
        expect(BraacketTournament.slug_from_url('https://braacket.com/tournament')).to eq(nil)
      end

      it 'with bad host' do
        expect(BraacketTournament.slug_from_url('https://goo.gl/foo')).to eq(nil)
      end
    end
  end

end
