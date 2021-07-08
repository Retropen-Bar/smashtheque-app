module ActiveAdmin
  module RecurringTournamentsHelper
    def recurring_tournament_discord_guild_select_collection
      DiscordGuild.order(:name).map do |discord_guild|
        [
          discord_guild.decorate.name_or_id,
          discord_guild.id
        ]
      end
    end

    def recurring_tournament_level_select_collection
      RecurringTournament::LEVELS.map do |v|
        [
          RecurringTournament.human_attribute_name("level.#{v}"),
          v
        ]
      end
    end

    def recurring_tournament_recurring_type_select_collection
      RecurringTournament::RECURRING_TYPES.map do |v|
        [
          RecurringTournament.human_attribute_name("recurring_type.#{v}"),
          v
        ]
      end
    end

    def recurring_tournament_wday_select_collection
      ((1..6).to_a + [0]).map do |v|
        [
          I18n.t('date.day_names')[v].titlecase,
          v
        ]
      end
    end

    def recurring_tournament_size_select_collection
      RecurringTournament::SIZES.map do |v|
        [
          RecurringTournamentDecorator.size_name(v),
          v
        ]
      end
    end

    def recurring_tournament_locality_select_collection
      RecurringTournament.pluck('DISTINCT locality').reject(&:blank?).sort
    end

    def recurring_tournament_community_select_collection
      Community.order('LOWER(name)').pluck(:name, :id)
    end
  end
end
