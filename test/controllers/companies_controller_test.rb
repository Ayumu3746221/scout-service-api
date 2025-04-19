require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @industry = Industry.create!(name: "IT・通信")
  end

  test "should create company with recruiter" do
    assert_difference("Company.count", 1) do
      assert_difference("User.count", 1) do
        assert_difference("Recruiter.count", 1) do
          post create_with_recruiter_companies_path, params: {
            company: {
              name: "新しい会社",
              email: "new_company@example.com",
              industry_id: @industry.id
            },
            user: {
              email: "new_recruiter@example.com",
              password: "password123",
              password_confirmation: "password123"
            },
            recruiter: {
              name: "採用担当者"
            }
          }, as: :json
        end
      end
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Company and recruiter created successfully", json_response["message"]
    assert_equal "recruiter", json_response["user"]["role"]
  end

  test "should not create company with invalid data" do
    assert_no_difference([ "Company.count", "User.count", "Recruiter.count" ]) do
      post create_with_recruiter_companies_path, params: {
        company: {
          name: "",  # 名前が空
          email: "invalid-email",  # 無効なメール
          industry_id: 9999  # 存在しない業界ID
        },
        user: {
          email: "new_recruiter@example.com",
          password: "password123",
          password_confirmation: "password123"
        },
        recruiter: {
          name: "採用担当者"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should not create company with invalid user data" do
    assert_no_difference([ "Company.count", "User.count", "Recruiter.count" ]) do
      post create_with_recruiter_companies_path, params: {
        company: {
          name: "テスト会社",
          email: "test_company@example.com",
          industry_id: @industry.id
        },
        user: {
          email: "invalid-email",  # 無効なメール
          password: "pass",  # 短いパスワード
          password_confirmation: "different"  # 一致しないパスワード
        },
        recruiter: {
          name: "採用担当者"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
  end
end
