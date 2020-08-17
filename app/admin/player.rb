ActiveAdmin.register Player do

  decorate_with PlayerDecorator

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :name
    column :characters
    column :city
    column :team
    column :created_at
    actions
  end

  filter :name
  filter :characters
  filter :city
  filter :team

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
      row :characters
      row :city
      row :team
      row :created_at
      row :updated_at
    end
  end

end
