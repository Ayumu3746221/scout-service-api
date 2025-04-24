require "test_helper"

class JobPostingTest < ActiveSupport::TestCase
  setup do
    # テスト用のIndustryを作成
    @industry = Industry.create!(name: "IT")
    # テスト用のCompanyを作成
    @company = Company.create!(
      name: "テスト株式会社",
      email: "test@example.com",
      industry: @industry
    )

    # テスト用のJobPostingを作成
    @active_job_posting = JobPosting.create!(
      company: @company,
      title: "Railsエンジニア募集",
      description: "バックエンドの開発者を募集しています",
      requirements: "Ruby on Railsの経験",
      is_active: true
    )

    @inactive_job_posting = JobPosting.create!(
      company: @company,
      title: "フロントエンドエンジニア募集",
      description: "フロントエンド開発者を募集しています",
      requirements: "React.jsの経験",
      is_active: false
    )

    # 別会社用のIndustryを作成
    @other_industry = Industry.create!(name: "Finance")

    # 別の会社とそのJobPosting
    @other_company = Company.create!(
      name: "別の会社",
      email: "other@example.com",
      industry: @other_industry
    )

    @other_job_posting = JobPosting.create!(
      company: @other_company,
      title: "データサイエンティスト募集",
      description: "データ分析チームのメンバーを募集",
      requirements: "Python, 統計学の知識",
      is_active: true
    )
  end

  test "should be valid with all required attributes" do
    job_posting = JobPosting.new(
      company: @company,
      title: "テスト求人"
    )
    assert job_posting.valid?, "JobPosting with all required attributes should be valid"
  end

  test "should not be valid without a title" do
    job_posting = JobPosting.new(
      company: @company,
      title: nil
    )
    assert_not job_posting.valid?, "JobPosting without a title should not be valid"
    assert_includes job_posting.errors[:title], "can't be blank"
  end

  test "should not be valid without a company" do
    job_posting = JobPosting.new(
      title: "テスト求人"
    )
    assert_not job_posting.valid?, "JobPosting without a company should not be valid"
    assert_includes job_posting.errors[:company], "must exist"
  end

  test "is_active should default to true" do
    job_posting = JobPosting.new(
      company: @company,
      title: "テスト求人"
    )
    assert_equal true, job_posting.is_active, "is_active should default to true"
  end

  test "should belong to a company" do
    assert_equal @company, @active_job_posting.company
  end

  test "should filter active job postings" do
    # アクティブな求人のみをフィルタリング
    active_postings = JobPosting.where(is_active: true)

    assert_includes active_postings, @active_job_posting
    assert_includes active_postings, @other_job_posting
    assert_not_includes active_postings, @inactive_job_posting
  end
end
