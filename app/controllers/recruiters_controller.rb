class RecruitersController < ApplicationController
  include AuthenticationConcern

  before_action :authenticate_user!
  before_action :authorize_recruiter!

  # Handlerを利用したアプローチではうまく役割分担できないので
  # Controllerで直接処理を行う
  def create
    user = User.new(user_params.merge(role: "recruiter"))
    if user.save
      recruiter = Recruiter.new(
        name: recruiter_params[:name],
        user: user,
        company: current_company
      )

      if recruiter.save
        render json: {
          message: "Recruiter created successfully",
          user: user.as_json(only: [ :id, :email, :role ])
        }, status: :created and return
      else
        render json: { errors: recruiter.errors.full_messages }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    else
      render jsom: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authorize_recruiter!
    unless current_user.recruiter?
      render json: { error: "Forbidden" }, status: :forbidden
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def recruiter_params
    params.require(:recruiter).permit(:name)
  end
end
