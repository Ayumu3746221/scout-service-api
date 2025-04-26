require "test_helper"

class ApplicationTest < ActiveSupport::TestCase
  def setup
    # テスト用のIndustryを作成
    @industry = Industry.create!(name: "IT")

    # テスト用のCompanyを作成
    @company = Company.create!(
      name: "テスト株式会社",
      email: "company@example.com",
      industry: @industry
    )

    # 求人を作成
    @job_posting = JobPosting.create!(
      company: @company,
      title: "Railsエンジニア募集",
      description: "バックエンドの開発者を募集しています",
      requirements: "Ruby on Railsの経験",
      is_active: true
    )

    # 学生用のユーザーとレコード
    @student_user = User.create!(
      email: "student@example.com",
      password: "password",
      password_confirmation: "password",
      role: "student"
    )

    @student = Student.create!(
      user: @student_user,
      name: "テスト学生"
    )

    # 採用担当者用のユーザーとレコード
    @recruiter_user = User.create!(
      email: "recruiter@example.com",
      password: "password",
      password_confirmation: "password",
      role: "recruiter"
    )

    @recruiter = Recruiter.create!(
      user: @recruiter_user,
      company: @company,
      name: "採用担当者"
    )
  end

  test "should be valid with all required attributes" do
    application = Application.new(
      job_posting: @job_posting,
      student: @student,
      status: "pending"
    )
    assert application.valid?, "Application with all required attributes should be valid"
  end

  test "should not be valid without a job_posting" do
    application = Application.new(
      student: @student,
      status: "pending"
    )
    assert_not application.valid?, "Application should not be valid without a job_posting"
    assert_includes application.errors[:job_posting], "must exist"
  end

  test "should not be valid without a student" do
    application = Application.new(
      job_posting: @job_posting,
      status: "pending"
    )
    assert_not application.valid?, "Application should not be valid without a student"
    assert_includes application.errors[:student], "must exist"
  end

  test "should have default status of pending" do
    application = Application.new(
      job_posting: @job_posting,
      student: @student
    )
    assert application.valid?, "Application should be valid with default status"
    assert_equal "pending", application.status, "Default status should be 'pending'"
  end

  test "should only allow valid status values" do
    valid_statuses = [ "pending", "accepted", "rejected" ]

    valid_statuses.each do |status|
      application = Application.new(
        job_posting: @job_posting,
        student: @student,
        status: status
      )
      assert application.valid?, "Application with status '#{status}' should be valid"
    end

    application = Application.new(
      job_posting: @job_posting,
      student: @student,
      status: "invalid_status"
    )
    assert_not application.valid?, "Application with invalid status should not be valid"
  end

  test "should not allow duplicate application for same job and student" do
    # 最初の応募を作成
    Application.create!(
      job_posting: @job_posting,
      student: @student,
      status: "pending"
    )

    # 同じ求人と学生で2つ目の応募を作成しようとする
    duplicate_application = Application.new(
      job_posting: @job_posting,
      student: @student,
      status: "pending"
    )

    assert_not duplicate_application.valid?, "Should not allow duplicate applications"
    assert_includes duplicate_application.errors[:student_id], "has already applied to this job posting"
  end

  test "should belong to a job_posting" do
    application = Application.create!(
      job_posting: @job_posting,
      student: @student,
      status: "pending"
    )
    assert_equal @job_posting, application.job_posting
  end

  test "should belong to a student" do
    application = Application.create!(
      job_posting: @job_posting,
      student: @student,
      status: "pending"
    )
    assert_equal @student, application.student
  end

  test "should be able to update status" do
    application = Application.create!(
      job_posting: @job_posting,
      student: @student,
      status: "pending"
    )

    assert application.update(status: "accepted"), "Should be able to update status"
    assert_equal "accepted", application.reload.status
  end
end
