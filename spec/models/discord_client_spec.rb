require 'rails_helper'

RSpec.describe DiscordClient, type: :model do
  describe '.invitation_code_from_invitation_url' do
    [
      [nil, ''],
      ['', ''],
      ['http://', ''],
      ['https://', ''],
      ['discord.gg/', ''],
      ['discord.gg/ABC', 'ABC'],
      ['discord.com/ABC', 'ABC'],
      ['discordapp.com/ABC', 'ABC'],
      ['https://ABC', 'ABC'],
      ['https://discord.gg/invite/ABC', 'ABC'],
      ['https://discord.gg/ABC', 'ABC'],
      ['https://discord.com/invite/ABC', 'ABC'],
      ['https://discord.com/ABC', 'ABC'],
      ['https://discordapp.com/invite/ABC', 'ABC'],
      ['https://discordapp.com/ABC', 'ABC']
    ].each do |values|
      it values.first do
        expect(described_class.invitation_code_from_invitation_url(values.first)).to eq(values.last)
      end
    end
  end
end
