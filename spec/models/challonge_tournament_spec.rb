# == Schema Information
#
# Table name: challonge_tournaments
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
#  challonge_id           :integer          not null
#
# Indexes
#
#  index_challonge_tournaments_on_challonge_id  (challonge_id) UNIQUE
#  index_challonge_tournaments_on_slug          (slug) UNIQUE
#
require 'rails_helper'

RSpec.describe ChallongeTournament, type: :model do

  context 'helpers' do
    describe '.slug_from_url' do
      it 'with perfect URL' do
        expect(ChallongeTournament.slug_from_url('https://challonge.com/foo')).to eq('foo')
      end

      it 'with perfect URL with locale' do
        expect(ChallongeTournament.slug_from_url('https://challonge.com/fr/foo')).to eq('foo')
      end

      it 'with URL a bit too long' do
        expect(ChallongeTournament.slug_from_url('https://challonge.com/fr/foo/')).to eq('foo')
      end

      it 'with URL too long' do
        expect(ChallongeTournament.slug_from_url('https://challonge.com/fr/foo/ranks')).to eq('foo')
      end

      it 'with only slug' do
        expect(ChallongeTournament.slug_from_url('foo')).to eq('foo')
      end

      it 'with nil' do
        expect(ChallongeTournament.slug_from_url(nil)).to eq(nil)
      end

      it 'with empty URL' do
        expect(ChallongeTournament.slug_from_url('')).to eq(nil)
      end

      it 'with bad URL' do
        expect(ChallongeTournament.slug_from_url('https://challonge.com/fr/')).to eq(nil)
      end

      it 'with bad URL' do
        expect(ChallongeTournament.slug_from_url('https://challonge.com/fr')).to eq(nil)
      end

      it 'with bad host' do
        expect(ChallongeTournament.slug_from_url('https://goo.gl/foo')).to eq(nil)
      end
    end
  end

end
