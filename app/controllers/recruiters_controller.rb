class RecruitersController < ApplicationController
  include AuthenticationConcern

  before_action :authenticate_user!
  before_action :authorize_recruiter!

  # Handlerを利用したアプローチではうまく役割分担できないので
  # Controllerで直接処理を行う
  def create
    success = false
    user = nil
    error_messages = nil

    ActiveRecord::Base.transaction do
      user = User.new(user_params.merge(role: "recruiter"))

      if user.save
        recruiter = Recruiter.new(
          name: recruiter_params[:name],
          user: user,
          company: current_user.recruiter.company
        )

        if recruiter.save
          success = true
        else
          error_messages = recruiter.errors.full_messages
          raise ActiveRecord::Rollback
        end
      else
        error_messages = user.errors.full_messages
        raise ActiveRecord::Rollback
      end
    end

    if success
      render json: {
        message: "Recruiter created successfully",
        user: user.as_json(only: [ :id, :email, :role ])
      }, status: :created
    else
      render json: { errors: error_messages || [ "An error occurred" ] }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def recruiter_params
    params.require(:recruiter).permit(:name)
  end
end
