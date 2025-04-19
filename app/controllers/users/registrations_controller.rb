class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionFix
  respond_to :json

  def create
    context = {
      user_params: sign_up_params,
      student_params: student_params
    }

    success = false
    error_message = nil

    ActiveRecord::Base.transaction do
      begin
        user_creation = Creation::UserCreationHandler.new(role: "student")
        student_creation = Creation::StudentCreationHandler.new

        user_creation.set_next(student_creation)

        if user_creation.handle(context)
          success = true
          @user = context[:user]
        else
          error_message = "Failed to create records"
          raise ActiveRecord::Rollback
        end
      rescue CreationError => e
        error_message = e.message
        raise ActiveRecord::Rollback
      end
    end

    if success
      sign_in(@user)
      respond_with(@user)
    else
      render json: {
        message: "Sign up failure.",
        errors: error_message || "処理に失敗しました"
      }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation
    ).merge(role: "student")
  end

  def student_params
    params.require(:student).permit(
      :name
    )
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
