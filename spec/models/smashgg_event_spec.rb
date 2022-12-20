# == Schema Information
#
# Table name: smashgg_events
#
#  id                    :bigint           not null, primary key
#  is_ignored            :boolean          default(FALSE), not null
#  is_online             :boolean
#  name                  :string
#  num_entrants          :integer
#  slug                  :string           not null
#  start_at              :datetime
#  tournament_name       :string
#  tournament_slug       :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  smashgg_id            :integer          not null
#  top1_smashgg_user_id  :bigint
#  top2_smashgg_user_id  :bigint
#  top3_smashgg_user_id  :bigint
#  top4_smashgg_user_id  :bigint
#  top5a_smashgg_user_id :bigint
#  top5b_smashgg_user_id :bigint
#  top7a_smashgg_user_id :bigint
#  top7b_smashgg_user_id :bigint
#  tournament_id         :integer
#  tournament_owner_id   :bigint
#
# Indexes
#
#  index_smashgg_events_on_slug                   (slug) UNIQUE
#  index_smashgg_events_on_smashgg_id             (smashgg_id) UNIQUE
#  index_smashgg_events_on_top1_smashgg_user_id   (top1_smashgg_user_id)
#  index_smashgg_events_on_top2_smashgg_user_id   (top2_smashgg_user_id)
#  index_smashgg_events_on_top3_smashgg_user_id   (top3_smashgg_user_id)
#  index_smashgg_events_on_top4_smashgg_user_id   (top4_smashgg_user_id)
#  index_smashgg_events_on_top5a_smashgg_user_id  (top5a_smashgg_user_id)
#  index_smashgg_events_on_top5b_smashgg_user_id  (top5b_smashgg_user_id)
#  index_smashgg_events_on_top7a_smashgg_user_id  (top7a_smashgg_user_id)
#  index_smashgg_events_on_top7b_smashgg_user_id  (top7b_smashgg_user_id)
#  index_smashgg_events_on_tournament_owner_id    (tournament_owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (top1_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top2_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top3_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top4_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top5a_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top5b_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top7a_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top7b_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (tournament_owner_id => smashgg_users.id)
#
require 'rails_helper'

RSpec.describe SmashggEvent, type: :model do
  describe '#is_short_url?' do
    %w[
      https://smash.gg/foo
      https://start.gg/foo
    ].each do |url|
      it url do
        expect(SmashggEvent.is_short_url?(url)).to be_truthy
      end
    end

    [
      nil,
      '',
      'https://smash.gg/',
      'https://start.gg/',
      'https://foo.fr/',
      'https://foo.fr/bar'
    ].each do |url|
      it url do
        expect(SmashggEvent.is_short_url?(url)).to be_falsey
      end
    end
  end

  describe '#slug_from_url' do
    [
      [nil, nil],
      ['https://smash.gg/tournament/foo/event/bar', 'tournament/foo/event/bar'],
      ['https://www.start.gg/tournament/foo/event/bar', 'tournament/foo/event/bar']
    ].each do |values|
      it values.first do
        expect(SmashggEvent.slug_from_url(values.first)).to eq(values.last)
      end
    end
  end
end
