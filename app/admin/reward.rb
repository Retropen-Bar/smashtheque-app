ActiveAdmin.register Reward do

  decorate_with ActiveAdmin::RewardDecorator

  has_paper_trail

  # menu label: '<i class="fas fa-fw fa-users"></i>Équipes'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :name
    column :image do |decorated|
      decorated.badge
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :name

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :name
      f.input :image
      f.input :style
    end
    f.actions
  end

  permit_params :name, :image, :style

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :badge do |decorated|
        decorated.badge
      end
      row :image do |decorated|
        decorated.image_tag(max_width: 64, style: "background: black")
      end
      row :style do |decorated|
        decorated.formatted_style
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
