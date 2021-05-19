module HasTwitter
  extend ActiveSupport::Concern

  included do

    # ---------------------------------------------------------------------------
    # HELPERS
    # ---------------------------------------------------------------------------

    def twitter_username=(name)
      super (name || '').gsub('https://', '')
                        .gsub('http://', '')
                        .gsub('twitter.com/', '')
                        .strip
                        .delete_prefix('@')
    end

  end
end
