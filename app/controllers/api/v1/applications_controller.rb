# このコントローラーは、完全にAIが生成したコントローラーです。

class Api::V1::ApplicationsController < ApplicationController
  include AuthenticationConcern
  before_action :authenticate_user!
  before_action :authorize_student!, only: [ :create ]
  before_action :set_job_posting, only: [ :create ]
  before_action :authorize_recruiter!, only: [ :index, :update ]

  # GET /api/v1/applications
  # リクルーター向け - 自社の求人への応募一覧
  def index
    @company = current_user.recruiter.company
    @applications = Application.joins(:job_posting)
                              .where(job_postings: { company_id: @company.id })
                              .order(created_at: :desc)

    render json: {
      applications: @applications.as_json(
        except: [ :updated_at ],
        include: {
          student: { only: [ :id, :name ] },
          job_posting: { only: [ :id, :title ] }
        }
      )
    }
  end

  # POST /api/v1/job_postings/:job_posting_id/apply
  # 学生向け - 求人に応募する
  def create
    @application = Application.new(
      job_posting: @job_posting,
      student: current_user.student,
      message: application_params[:message]
    )

    if @application.save
      render json: {
        message: "Successfully applied to job",
        application: @application.as_json(
          except: [ :updated_at ],
          include: {
            job_posting: { only: [ :id, :title ] }
          }
        )
      }, status: :created
    else
      render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/applications/:id
  # リクルーター向け - 応募のステータス更新
  def update
    @application = Application.find(params[:id])

    # 自社の求人への応募かチェック
    unless @application.job_posting.company_id == current_user.recruiter.company_id
      return render json: { error: "Not authorized to update this application" }, status: :forbidden
    end

    if @application.update(status: params[:status])
      # ステータス変更の通知を学生に送信
      Notification.create!(
        user: @application.student.user,
        content: "あなたの「#{@application.job_posting.title}」への応募が#{status_message(params[:status])}されました",
        notifiable: @application,
        notification_type: "application_status_changed"
      )

      render json: {
        message: "Application status updated successfully",
        application: @application.as_json(
          except: [ :updated_at ],
          include: {
            student: { only: [ :id, :name ] },
            job_posting: { only: [ :id, :title ] }
          }
        )
      }
    else
      render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def application_params
    params.require(:application).permit(:message)
  end

  def set_job_posting
    @job_posting = JobPosting.find(params[:id])

    # 非アクティブな求人には応募できないようにする
    unless @job_posting.is_active
      render json: { error: "This job posting is not active" }, status: :bad_request
    end
  end

  def status_message(status)
    case status
    when "accepted" then "承認"
    when "rejected" then "拒否"
    when "pending" then "保留"
    else status
    end
  end

  def authorize_student!
    unless current_user.student?
      render json: { error: "Only students can apply to job postings" }, status: :forbidden
    end
  end

  def authorize_recruiter!
    unless current_user.recruiter?
      render json: { error: "Only recruiters can access this resource" }, status: :forbidden
    end
  end
end
