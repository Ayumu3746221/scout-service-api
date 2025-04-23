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

    ActiveRecord::Base.transaction do
      begin
        if @job_posting.save

          if params[:job_posting][:skill_ids].present?
            job_posting_skills_create
          end

        else
          raise ActiveRecord::Rollback
        end
      rescue => e
        Rails.logger.error("Job posting creation failed: #{e.message}")
        raise ActiveRecord::Rollback
      end
    end

    if @job_posting.persisted?
      render json: {
        message: "Job posting created successfully",
        job_posting: @job_posting.as_json(
          except: [ :created_at, :updated_at ],
          include: {
            skills: { only: [ :id, :name ] }
          }
        )
      }, status: :created
    else
      render json: {
        message: "Job posting creation failed",
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

  # 既存関係のクリーンアップに使う
  def job_posting_skills_destroy
    @job_posting.job_posting_skills.destroy_all
  end

  def job_posting_skills_create
    params[:job_posting][:skill_ids].each do |skill_id|
      @job_posting.job_posting_skills.create!(skill_id: skill_id)
    end
  end
end
