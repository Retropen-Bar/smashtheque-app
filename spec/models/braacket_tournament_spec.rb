# == Schema Information
#
# Table name: braacket_tournaments
#
#  id                     :bigint           not null, primary key
#  name                   :string
#  participants_count     :integer
#  slug                   :string           not null
#  start_at               :datetime
#  top1_participant_name  :string
#  top2_participant_name  :string
#  top3_participant_name  :string
#  top4_participant_name  :string
#  top5a_participant_name :string
#  top5b_participant_name :string
#  top7a_participant_name :string
#  top7b_participant_name :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_braacket_tournaments_on_slug  (slug) UNIQUE
#
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
