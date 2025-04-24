class Api::V1::JobPostingsController < ApplicationController
  include AuthenticationConcern

  before_action :authenticate_user!, only: [ :create, :update, :toggle_active ]
  before_action :authorize_recruiter!, only: [ :create, :update, :toggle_active ]
  before_action :set_current_company, only: [ :create, :update, :toggle_active ]
  before_action :set_job_posting, only: [ :show, :update, :toggle_active ]
  before_action :authorize_job_posting, only: [ :update, :toggle_active ]

  def index
    @job_postings = JobPosting.where(is_active: true)

    if params[:skill_id].present?
      @job_postings = @job_postings.joins(:job_posting_skills)
                                  .where(job_posting_skills: { skill_id: params[:skill_id] })
                                  .distinct
    end

    if params[:industry_id].present?
      @job_postings = @job_postings.joins(:job_posting_industries)
                                  .where(job_posting_industries: { industry_id: params[:industry_id] })
                                  .distinct
    end

    @job_postings = @job_postings.page(params[:page]).per(10) if defined?(Kaminari)

    render json: {
      job_postings: @job_postings.as_json(
        except: [ :created_at, :updated_at ],
        include: {
          company: { only: [ :id, :name ] },
          skills: { only: [ :id, :name ] },
          industries: { only: [ :id, :name ] }
        }
      )
    }, status: :ok
  end

  def show
    render json: {
      job_posting: @job_posting.as_json(
        except: [ :created_at, :updated_at ],
        include: {
          company: { only: [ :id, :name ] },
          skills: { only: [ :id, :name ] },
          industries: { only: [ :id, :name ] }
        }
      )
    }, status: :ok
  end

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

          if params[:job_posting][:industry_ids].present?
            job_posting_industries_create
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

  def update
    ActiveRecord::Base.transaction do
      begin
        @job_posting.update!(job_posting_params)

        if params[:job_posting][:skill_ids].present?
          job_posting_skills_destroy
          job_posting_skills_create
        end

        if params[:job_posting][:industry_ids].present?
          job_posting_industries_destroy
          job_posting_industries_create
        end
      rescue => e
        Rails.logger.error("Job posting update failed: #{e.message}")
        render json: { errors: e.message }, status: :unprocessable_entity
        return
      end
    end

    @job_posting.reload

    render json: {
      message: "Job posting updated successfully",
      job_posting: @job_posting.as_json(
        except: [ :created_at, :updated_at ],
        include: {
          company: { only: [ :id, :name ] },
          skills: { only: [ :id, :name ] },
          industries: { only: [ :id, :name ] }
        }
      )
    }, status: :ok
  end

  def toggle_active
    is_active = params[:is_active]

    if @job_posting.update(is_active: is_active)
      render json: {
        message: "Job posting status updated successfully",
        job_posting: {
          id: @job_posting.id,
          title: @job_posting.title,
          is_active: @job_posting.is_active
        }
      }, status: :ok
    else
      render json: {
        message: "Failed to update job posting status",
        errors: @job_posting.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_job_posting
    @job_posting = JobPosting.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Job posting not found" }, status: :not_found
  end

  def set_current_company
    @current_company = current_company

    unless @current_company
      render json: { error: "You must associate with a company" }, status: :forbidden
      nil
    end
  end

  def authorize_job_posting
    unless @job_posting.company_id == @current_company.id
      render json: { error: "You are not authorized to update this job posting" }, status: :forbidden
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

  # 既存関係のクリーンアップに使う
  def job_posting_industries_destroy
    @job_posting.job_posting_industries.destroy_all
  end

  def job_posting_industries_create
    params[:job_posting][:industry_ids].each do |industry_id|
      @job_posting.job_posting_industries.create!(industry_id: industry_id)
    end
  end
end
