ActiveAdmin.register Player do

  decorate_with PlayerDecorator

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :name
    column :characters do |decorated|
      decorated.characters_links.join(', ').html_safe
    end
    column :city do |decorated|
      decorated.city_link
    end
    column :team do |decorated|
      decorated.team_link
    end
    column :created_at
    actions
  end

  filter :name
  filter :characters,
         as: :select,
         collection: proc { Character.order(:name).decorate },
         input_html: { multiple: true, data: { select2: {} } }
  filter :city,
         as: :select,
         collection: proc { City.order(:name).decorate },
         input_html: { multiple: true, data: { select2: {} } }
  filter :team,
         as: :select,
         collection: proc { Team.order(:name).decorate },
         input_html: { multiple: true, data: { select2: {} } }

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :name
      f.input :characters,
              collection: Character.order(:name),
              input_html: { multiple: true, data: { select2: {} } }
      f.input :city,
              collection: City.order(:name),
              input_html: { data: { select2: {} } }
      f.input :team,
              collection: Team.order(:name),
              input_html: { data: { select2: {} } }
    end
    f.actions
  end

  permit_params :name, :city_id, :team_id, character_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :characters do |decorated|
        decorated.characters_links.join('<br/>').html_safe
      end
      row :city do |decorated|
        decorated.city_link
      end
      row :team do |decorated|
        decorated.team_link
      end
      row :created_at
      row :updated_at
    end
  end

end
