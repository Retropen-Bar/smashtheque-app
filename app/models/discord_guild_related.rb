# == Schema Information
#
# Table name: discord_guild_relateds
#
#  id               :bigint           not null, primary key
#  related_type     :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  discord_guild_id :bigint
#  related_id       :bigint
#
# Indexes
#
#  index_dgr_on_all                                             (discord_guild_id,related_type,related_id) UNIQUE
#  index_discord_guild_relateds_on_discord_guild_id             (discord_guild_id)
#  index_discord_guild_relateds_on_related_type_and_related_id  (related_type,related_id)
#
class DiscordGuildRelated < ApplicationRecord

  def self.related_types
    [
      Character,
      Location,
      Player,
      Team
    ]
  end

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :discord_guild
  belongs_to :related, polymorphic: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    RetropenBotScheduler.rebuild_discord_guilds_chars_list
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.by_related_type(v)
    where(related_type: v)
  end

  def self.by_related_id(v)
    where(related_id: v)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def related_gid
    self.related&.to_global_id&.to_s
  end

  def related_gid=(gid)
    self.related = GlobalID::Locator.locate gid
  end

  def self.related_autocomplete(term)
    searchable_types = related_types.map(&:to_s)

    {
      results: PgSearch.multisearch(term).where(searchable_type: searchable_types).map do |document|
        model = if document.searchable_type == 'Location'
          # hack for weird bug
          Location.find(document.searchable_id).decorate
        else
          document.searchable.decorate
        end
        {
          id: model.to_global_id.to_s,
          text: model.decorate.autocomplete_name
        }
      end
    }
  end

  def as_json(options = nil)
    super((options || {}).merge(
      only: %i(related_type),
      include: {
        related: {}
      }
    ))
  end

end
