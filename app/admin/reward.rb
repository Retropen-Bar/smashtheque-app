ActiveAdmin.register Reward do

  decorate_with ActiveAdmin::RewardDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess"></i>Compétition'.html_safe,
       label: '<i class="fas fa-fw fa-trophy"></i>Récompenses'.html_safe,
       priority: 2

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  order_by(:name) do |order_clause|
    if order_clause.order == 'desc'
      'category DESC, level1 DESC, level2 DESC'
    else
      'category, level1, level2'
    end
  end
  order_by(:level) do |order_clause|
    if order_clause.order == 'desc'
      'level1 DESC, level2 DESC'
    else
      'level1, level2'
    end
  end
  config.sort_order = 'name_asc'

  index do
    selectable_column
    id_column
    column :name, sortable: true do |decorated|
      link_to decorated.name, [:admin, decorated.model]
    end
    column :category do |decorated|
      decorated.category_status
    end
    column :level, sortable: true
    column :emoji do |decorated|
      decorated.emoji_image_tag(max_height: 32)
    end
    column :image do |decorated|
      decorated.image_image_tag(max_height: 32)
    end
    column :conditions do |decorated|
      decorated.conditions_admin_link
    end
    column :met_conditions do |decorated|
      decorated.met_conditions_admin_link
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true

  scope :online_1v1, group: :online
  scope :online_2v2, group: :online

  scope :online_1v1, group: :offline
  scope :online_2v2, group: :offline

  filter :category,
         as: :select,
         collection: proc { reward_category_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :level1
  filter :level2

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    columns do
      column do
        f.inputs do
          f.input :category,
                  collection: reward_category_select_collection
          f.input :level1
          f.input :level2
          f.input :emoji
          f.input :image,
                  as: :file,
                  hint: 'Laissez vide pour ne pas changer',
                  input_html: {
                    accept: 'image/*',
                    data: {
                      previewpanel: 'current-image'
                    }
                  }
        end
        f.actions
      end
      column do
        panel 'Emoji', id: 'current-emoji' do
          f.object.decorate.emoji_image_tag
        end
        panel 'Image', id: 'current-image' do
          f.object.decorate.image_image_tag
        end
      end
    end
  end

  permit_params :category, :level1, :level2, :emoji, :image

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :category do |decorated|
        decorated.category_status
      end
      row :level1
      row :level2
      row :emoji
      row :emoji do |decorated|
        decorated.emoji_image_tag(max_height: 64)
      end
      row :image do |decorated|
        decorated.image_image_tag(max_height: 64)
      end
      row :badge do |decorated|
        decorated.all_badge_sizes(count: 99)
      end
      if resource.is_1v1?
        row :reward_conditions do |decorated|
          decorated.reward_conditions_admin_link
        end
        row :player_reward_conditions do |decorated|
          decorated.player_reward_conditions_admin_link
        end
        row :players do |decorated|
          decorated.players_admin_link
        end
      end
      if resource.is_2v2?
        row :reward_duo_conditions do |decorated|
          decorated.reward_duo_conditions_admin_link
        end
        row :duo_reward_duo_conditions do |decorated|
          decorated.duo_reward_duo_conditions_admin_link
        end
        row :duos do |decorated|
          decorated.duos_admin_link
        end
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
