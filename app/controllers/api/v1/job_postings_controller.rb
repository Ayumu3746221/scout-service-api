class Api::V1::JobPostingsController < ApplicationController
  include AuthenticationConcern

  before_action :authenticate_user!
  before_action :authorize_recruiter!
  before_action :set_current_company, only: [ :create ]

  def create
    @job_posting = JobPosting.new({
      company: @current_company,
      title: job_posting_params[:title],
      description: job_posting_params[:description],
      requirements: job_posting_params[:requirements],
      is_active: job_posting_params[:is_active] || false
    })

    if @job_posting.save
      render json: {
        message: "Job posting created successfully",
        job_posting: @job_posting.as_json(
          except: [ :created_at, :updated_at ],
          ) }, status: :created
    else
      render json: {
        message: "faild creating Job posting",
        errors: @job_posting.errors.full_messages
        }, status: :unprocessable_entity
    end
  end

  private

  def set_current_company
    @current_company = current_company

    unless @current_company
      render json: { error: "You must associate with a company" }, status: :forbidden
      nil
    end
  end

  def job_posting_params
    params.require(:job_posting).permit(
      :title,
      :description,
      :requirements,
      :is_active
    )
  end
end
