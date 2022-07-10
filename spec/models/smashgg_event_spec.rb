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
