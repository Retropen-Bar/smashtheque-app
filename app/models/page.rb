# == Schema Information
#
# Table name: pages
#
#  id         :bigint           not null, primary key
#  in_footer  :boolean          default(FALSE), not null
#  in_header  :boolean          default(FALSE), not null
#  is_draft   :boolean          default(FALSE), not null
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :bigint
#
# Indexes
#
#  index_pages_on_parent_id  (parent_id)
#  index_pages_on_slug       (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => pages.id)
#
class Page < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :parent, class_name: :Page, optional: true

  has_many :children, class_name: :Page, foreign_key: :parent_id

  has_rich_text :content

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :slug,
            presence: true,
            uniqueness: true,
            format: {
              with: Regexp.new('\A[a-z0-9]+(?:-[a-z0-9]+)*\z')
            }

  validates :name, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :orphan, -> { where(parent_id: nil) }
  scope :draft, -> { where(is_draft: true) }
  scope :header, -> { where(in_header: true) }
  scope :footer, -> { where(in_footer: true) }
  scope :published, -> { where(is_draft: false) }

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

end
