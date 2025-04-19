require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  def setup
    @industry = Industry.create!(name: "IT・通信")
  end

  test "should be valid with all required attributes" do
    company = Company.new(
      name: "テスト株式会社",
      email: "company@example.com",
      industry: @industry
    )
    assert company.valid?, "Company with all required attributes should be valid"
  end

  test "should not be valid without a name" do
    company = Company.new(
      email: "company@example.com",
      industry: @industry
    )
    assert_not company.valid?, "Company should not be valid without a name"
    assert_includes company.errors[:name], "can't be blank"
  end

  test "should not be valid without an email" do
    company = Company.new(
      name: "テスト株式会社",
      industry: @industry
    )
    assert_not company.valid?, "Company should not be valid without an email"
    assert_includes company.errors[:email], "can't be blank"
  end

  test "should not be valid with invalid email format" do
    company = Company.new(
      name: "テスト株式会社",
      email: "invalid-email",
      industry: @industry
    )
    assert_not company.valid?, "Company should not be valid with invalid email format"
    assert_includes company.errors[:email], "is invalid"
  end

  test "should not be valid without an industry" do
    company = Company.new(
      name: "テスト株式会社",
      email: "company@example.com"
    )
    assert_not company.valid?, "Company should not be valid without an industry"
    assert_includes company.errors[:industry_id], "can't be blank"
  end

  test "should destroy associated recruiters when company is destroyed" do
    company = Company.create!(
      name: "テスト株式会社",
      email: "company@example.com",
      industry: @industry
    )

    user = User.create!(
      email: "recruiter@example.com",
      password: "password",
      password_confirmation: "password",
      role: "recruiter"
    )

    recruiter = Recruiter.create!(
      user: user,
      company: company,
      name: "採用担当者"
    )

    assert_difference("Recruiter.count", -1) do
      company.destroy
    end
  end
end
