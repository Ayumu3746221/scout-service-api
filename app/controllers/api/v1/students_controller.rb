require "caxlsx"

class Api::V1::StudentsController < ApplicationController
  include AuthenticationConcern

  before_action :authenticate_user!, only: [ :update, :export ]
  before_action :set_student, only: [ :show, :update, :export ]
  before_action :authorize_student, only: [ :update, :export ]

  def show
    render json: @student.as_json(
        except: [ :created_at, :updated_at ],
        include: {
          industries: { only: [ :id, :name ] },
          skills: { only: [ :id, :name ] }
        }
      )
  end

  def update
    ActiveRecord::Base.transaction do
      begin
        @student.update!(student_params)

        if params[:student][:industry_ids].present?
          student_industries_destroy
          student_industries_create
        end

        if params[:student][:skill_ids].present?
          student_skills_destroy
          student_skills_create
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: :unprocessable_entity
        return
      end
    end

    @student.reload

    render json: {
      message: "Student updated successfully",
      student: @student.as_json(
        except: [ :created_at, :updated_at ],
        include: {
          industries: { only: [ :id, :name ] },
          skills: { only: [ :id, :name ] }
        }
      )
    }, status: :ok
  end

  def export
    student = Student.find(params[:id])

    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: "Student Info") do |sheet|
      # ヘッダー行
      sheet.add_row [ "自己紹介", "卒業年度", "学校名", "ポートフォリオURL" ]

      # データ行
      sheet.add_row [
        student.introduce,
        student.graduation_year,
        student.school,
        student.portfolio_url
      ]
    end

    send_data package.to_stream.read,
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
              filename: "#{student.name}_info.xlsx"
  end

  private

  def set_student
    @student = Student.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Student not found" }, status: :not_found
  end

  def student_params
    params.require(:student).permit(
      :name,
      :introduce,
      :graduation_year,
      :school,
      :portfolio_url,
    )
  end

  # 主に既存関係のリセットに使う
  def student_industries_destroy
    @student.student_industries.destroy_all
  end

  def student_industries_create
    params[:student][:industry_ids].each do |industry_id|
      @student.student_industries.create!(industry_id: industry_id)
    end
  end

  # 主に既存関係のリセットに使う
  def student_skills_destroy
    @student.student_skills.destroy_all
  end

  def student_skills_create
    params[:student][:skill_ids].each do |skill_id|
      @student.student_skills.create!(skill_id: skill_id)
    end
  end
end
