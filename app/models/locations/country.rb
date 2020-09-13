# == Schema Information
#
# Table name: locations
#
#  id         :bigint           not null, primary key
#  icon       :string
#  is_main    :boolean
#  latitude   :float
#  longitude  :float
#  name       :string
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_locations_on_type  (type)
#
class Locations::Country < Location

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def address
    name
  end

end
