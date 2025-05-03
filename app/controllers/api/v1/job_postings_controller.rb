class Api::V1::JobPostingsController < ApplicationController
  include AuthenticationConcern

  before_action :authenticate_user!, only: [ :create, :update, :toggle_active, :by_company ]
  before_action :authorize_recruiter!, only: [ :create, :update, :toggle_active, :by_company ]
  before_action :set_current_company, only: [ :create, :update, :toggle_active ]
  before_action :set_job_posting, only: [ :show, :update, :toggle_active ]
  before_action :authorize_job_posting, only: [ :update, :toggle_active ]

  def index
    @job_postings = JobPostingsQuery.new(JobPosting.all, params).call

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
    svc = JobPostings::ManageService.new(company: @current_company, params: params)
    jp  = svc.create
    render json: {
      message: "Job posting created successfully",
      job_posting: jp.as_json(
      except: [ :created_at, :updated_at ],
      include: {
        company: { only: [ :id, :name ] },
        skills: { only: [ :id, :name ] },
        industries: { only: [ :id, :name ] }
      }
      )
    }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def update
    svc = JobPostings::ManageService.new(company: @current_company, params: params)
    jp = svc.update(@job_posting)
    render json: {
      message: "Job posting updated successfully",
      job_posting: jp.as_json(
      except: [ :created_at, :updated_at ],
      include: {
        company: { only: [ :id, :name ] },
        skills: { only: [ :id, :name ] },
        industries: { only: [ :id, :name ] }
      })
    }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
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

  def by_company
    company_id = current_user.recruiter.company_id
    @job_postings = JobPosting.by_company(company_id)

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
end
