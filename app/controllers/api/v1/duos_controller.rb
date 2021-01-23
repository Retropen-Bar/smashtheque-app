class Api::V1::DuosController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_discord_id, allow_blank: true
  has_scope :by_name
  has_scope :by_name_like

  def index
    duos = apply_scopes(Duo.order("LOWER(name)")).includes(
      player1: { user: :discord_user },
      player2: { user: :discord_user }
    )
    render json: duos.as_json(reload: params[:reload] != '0')
  end

  def show
    duo = Duo.find(params[:id])
    render json: duo
  end

  def create
    attributes = duo_create_params
    name_confirmation = attributes.delete(:name_confirmation) == true

    existing_duos = Duo.by_name_like(attributes[:name]).pluck(:id)
    if existing_duos.any? && !name_confirmation
      render_errors({ name: :already_known, existing_ids: existing_duos }, :unprocessable_entity) and return
    end

    duo = Duo.new(attributes)
    if duo.save
      render json: duo, status: :created
    else
      render_errors duo.errors, :unprocessable_entity
    end
  end

  def update
    duo = Duo.find(params[:id])

    attributes = duo_update_params
    name_confirmation = attributes.delete(:name_confirmation) == true

    if attributes[:name] != duo.name
      existing_other_duos = Duo.where(name: attributes[:name]).pluck(:id)
      if existing_other_duos.any? && !name_confirmation
        render_errors({ name: :already_known, existing_ids: existing_other_duos }, :unprocessable_entity) and return
      end
    end

    duo.attributes = attributes
    if duo.save
      render json: duo
    else
      render_errors duo.errors, :unprocessable_entity
    end
  end

  private

  def duo_create_params
    params.require(:duo).permit(:name, :name_confirmation, :player1_id, :player2_id)
  end

  def duo_update_params
    params.require(:duo).permit(:name, :name_confirmation, :player1_id, :player2_id)
  end

end
