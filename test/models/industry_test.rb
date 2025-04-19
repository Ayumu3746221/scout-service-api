require "test_helper"

class IndustryTest < ActiveSupport::TestCase
  test "should be valid with a name" do
    industry = Industry.new(name: "IT・通信")
    assert industry.valid?, "Industry with a name should be valid"
  end

  test "should not be valid without a name" do
    industry = Industry.new
    assert_not industry.valid?, "Industry should not be valid without a name"
    assert_includes industry.errors[:name], "can't be blank"
  end

  test "should have many companies" do
    industry = Industry.create!(name: "IT・通信")

    company1 = Company.create!(
      name: "テスト株式会社1",
      email: "company1@example.com",
      industry: industry
    )

    company2 = Company.create!(
      name: "テスト株式会社2",
      email: "company2@example.com",
      industry: industry
    )

    assert_equal 2, industry.companies.size
    assert_includes industry.companies, company1
    assert_includes industry.companies, company2
  end

    test "should not be able to delete industry with associated companies" do
    industry = Industry.create!(name: "IT・通信")

    Company.create!(
      name: "テスト株式会社",
      email: "company@example.com",
      industry: industry
    )

    # 削除操作を試みる
    result = industry.destroy

    # 削除が失敗することをテスト（industry.destroyedが偽になる）
    assert_not result, "Industry should not be destroyed when it has companies"
    assert_not industry.destroyed?, "Industry should not be destroyed when it has companies"
    assert_equal 1, Industry.count, "Industry count should remain unchanged"
  end
end
