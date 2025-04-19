require "test_helper"

class RecruiterTest < ActiveSupport::TestCase
  def setup
    # テスト用のIndustryを作成
    @industry = Industry.create!(name: "IT・通信")

    # テスト用のCompanyを作成
    @company = Company.create!(
      name: "テスト株式会社",
      email: "test@example.com",
      description: "テスト企業の説明",
      industry: @industry
    )

    # テスト用のUserを作成
    @user = User.create!(
      email: "recruiter@example.com",
      password: "password",
      password_confirmation: "password",
      role: "recruiter"
    )
  end

  test "should be valid with all required attributes" do
    recruiter = Recruiter.new(
      user: @user,
      company: @company,
      name: "採用担当者"
    )
    assert recruiter.valid?, "Recruiter with all required attributes should be valid"
  end

  test "should not be valid without a name" do
    recruiter = Recruiter.new(
      user: @user,
      company: @company,
      name: nil
    )
    assert_not recruiter.valid?, "Recruiter should not be valid without a name"
    assert_includes recruiter.errors[:name], "can't be blank"
  end

  test "should not be valid without a user" do
    recruiter = Recruiter.new(
      company: @company,
      name: "採用担当者"
    )
    assert_not recruiter.valid?, "Recruiter should not be valid without a user"
  end

  test "should not be valid without a company" do
    recruiter = Recruiter.new(
      user: @user,
      name: "採用担当者"
    )
    assert_not recruiter.valid?, "Recruiter should not be valid without a company"
  end

  test "user_id should be the primary key" do
    recruiter = Recruiter.create!(
      user: @user,
      company: @company,
      name: "採用担当者"
    )

    # user_idがプライマリーキーとして使用されていることを確認
    assert_equal @user.id, recruiter.id
    assert_equal @user.id, recruiter.user_id
  end

  test "should not allow duplicate user_id" do
    # 最初のレコードを作成
    Recruiter.create!(
      user: @user,
      company: @company,
      name: "採用担当者"
    )

    # 別のユーザーを作成
    another_user = User.create!(
      email: "another_recruiter@example.com",
      password: "password",
      password_confirmation: "password",
      role: "recruiter"
    )

    # 同じユーザーで2つ目のレコードを作成しようとする
    duplicate_recruiter = Recruiter.new(
      user: @user,  # 同じユーザー
      company: @company,
      name: "別の採用担当者"
    )

    assert_not duplicate_recruiter.valid?, "Should not allow duplicate user_id"
    assert_includes duplicate_recruiter.errors[:user_id], "has already been taken"
  end

  test "should return correct jwt_payload" do
    recruiter = Recruiter.create!(
      user: @user,
      company: @company,
      name: "採用担当者"
    )

    # リロードして関連付けられたオブジェクトを確実に取得
    @user.reload

    payload = @user.jwt_payload

    # ペイロードにcompany_idが含まれていることを確認
    assert_equal @company.id, payload[:company_id]
  end

  test "should be destroyed when user is destroyed" do
    recruiter = Recruiter.create!(
      user: @user,
      company: @company,
      name: "採用担当者"
    )

    assert_difference("Recruiter.count", -1) do
      @user.destroy
    end
  end

  test "should be destroyed when company is destroyed" do
    recruiter = Recruiter.create!(
      user: @user,
      company: @company,
      name: "採用担当者"
    )

    assert_difference("Recruiter.count", -1) do
      @company.destroy
    end
  end
end
