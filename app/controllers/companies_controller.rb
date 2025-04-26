class CompaniesController < ApplicationController
  include AuthenticationConcern

  before_action :authenticate_user!
  before_action :authorize_recruiter!, only: [ :update ]
  before_action :current_company, only: [ :update ]
  before_action :set_current_company, only: [ :show ]
  skip_before_action :authenticate_user!, only: [ :create_with_recruiter, :index, :show ]

  def create_with_recruiter
    context = {
      company_params: company_params,
      user_params: user_params,
      recruiter_params: recruiter_params
    }

    success = false
    error_message = nil

    # rescue文:chainでエラーが発生した時に後続のchainにはエラーが伝播するが
    # 前のchainにエラーが伝播しないので、contoroller側でエラーをキャッチする必要がある
    ActiveRecord::Base.transaction do
      begin
        company_creation = Creation::CompanyCreationHandler.new
        user_creation = Creation::UserCreationHandler.new(role: "recruiter")
        recruiter_creation = Creation::RecruiterCreationHandler.new

        company_creation.set_next(user_creation)
        user_creation.set_next(recruiter_creation)

        if company_creation.handle(context)
          success = true
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
      render json: {
        message: "Company and recruiter created successfully",
        user: context[:user].as_json(only: [ :id, :email, :role ])
      }, status: :created
    else
      render json: {
        errors: error_message || "処理に失敗しました"
      }, status: :unprocessable_entity
    end
  end

  def index
    @companies = CompaniesQuery.new(Company.all, params).call

    render json: {
      companies: @companies.as_json(
      except: [ :created_at, :updated_at ],
      include: {
        industry: { only: [ :id, :name ] }
      })
      }, status: :ok
  end

  def show
    render json: {
      company: @company.as_json(
      except: [ :created_at, :updated_at ],
      include: {
        industry: { only: [ :id, :name ] }
      })
      }, status: :ok
  end

  def update
    @company = current_company
    if @company.update(company_params)
      render json: {
        message: "Company updated successfully",
        company: @company.as_json(only: [ :id, :name, :email, :industry_id ])
      }, status: :ok
    else
      render json: {
        errors: @company.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def company_params
    params.require(:company).permit(:name, :email, :address, :industry_id, :description)
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def recruiter_params
    params.require(:recruiter).permit(:name)
  end

  def set_current_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Company not found" }, status: :not_found
  end
end
