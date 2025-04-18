class CompaniesController < ApplicationController
  include AuthenticationConcern

  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [ :create_with_recruiter ]

  def create_with_recruiter
    context = {
      company_params: company_params,
      user_params: user_params,
      recruiter_params: recruiter_params
    }

    ActiveRecord::Base.transaction do
      # ハンドラーのチェーン構築
      # Chain of Responsibility
      company_creation = Creation::CompanyCreationHandler.new
      user_creation = Creation::UserCreationHandler.new(role: "recruiter")
      recruiter_creation = Creation::RecruiterCreationHandler.new

      company_creation.set_next(user_creation)
      user_creation.set_next(recruiter_creation)
      handlers = company_creation

      handlers.handle(context)

      render json: {
        message: "Company and recruiter created successfully",
        user: context[:user].as_json(only: [ :id, :email, :role ])
      }, status: :created
      rescue CreationError => e
        render json: {
          errors: e.message
        }, status: :unprocessable_entity
    end
  end

  private

  def company_params
    params.require(:company).permit(:name, :email, :industry_id)
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def recruiter_params
    params.require(:recruiter).permit(:name)
  end
end
