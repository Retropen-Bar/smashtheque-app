# == Schema Information
#
# Table name: locations
#
#  id         :bigint           not null, primary key
#  icon       :string
#  is_main    :boolean
#  name       :string
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_locations_on_type  (type)
#
class Locations::City < Location

end
