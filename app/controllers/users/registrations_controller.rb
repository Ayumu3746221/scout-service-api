class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionFix
  respond_to :json

  private

  def sign_up_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation
    ).merge(role: "student")
  end

  def respond_with(resource, _opts = {})
    register_success && return if resource.persisted?

    register_failed
  end

  def register_success
    render json: {
      message: "Signed up successfully.",
      user: @user.as_json(only: [ :id, :email, :role ])
    }, status: :ok
  end

  def register_failed
    render json: {
      message: "Signed up failure.",
      errors: resource.errors.full_messages
    }, status: :unprocessable_entity
  end
end
