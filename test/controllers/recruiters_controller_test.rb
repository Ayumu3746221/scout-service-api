require "test_helper"

class RecruitersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @industry = Industry.create!(name: "IT・通信")
    @company = Company.create!(
      name: "テスト株式会社",
      email: "company@example.com",
      industry: @industry
    )

    # ログイン用のリクルーター作成
    @user = User.create!(
      email: "admin_recruiter@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "recruiter"
    )

    @recruiter = Recruiter.create!(
      user: @user,
      company: @company,
      name: "管理者"
    )

    # JWT認証トークン取得
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    @token = response.headers["Authorization"].split(" ").last
  end

  test "should create new recruiter when authenticated as recruiter" do
    assert_difference("User.count", 1) do
      assert_difference("Recruiter.count", 1) do
        post recruiters_path, params: {
          user: {
            email: "new_recruiter@example.com",
            password: "password123",
            password_confirmation: "password123"
          },
          recruiter: {
            name: "新しい採用担当者"
          }
        },
        headers: { "Authorization" => "Bearer #{@token}" },
        as: :json
      end
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Recruiter created successfully", json_response["message"]
    assert_equal "recruiter", json_response["user"]["role"]
  end

  test "should not create recruiter without authentication" do
    assert_no_difference([ "User.count", "Recruiter.count" ]) do
      post recruiters_path, params: {
        user: {
          email: "unauthorized@example.com",
          password: "password123",
          password_confirmation: "password123"
        },
        recruiter: {
          name: "権限のない担当者"
        }
      }, as: :json
    end

    assert_response :unauthorized
  end

  test "should not create recruiter with invalid data" do
    assert_no_difference([ "User.count", "Recruiter.count" ]) do
      post recruiters_path, params: {
        user: {
          email: "invalid-email",
          password: "short",
          password_confirmation: "not-matching"
        },
        recruiter: {
          name: ""
        }
      },
      headers: { "Authorization" => "Bearer #{@token}" },
      as: :json
    end

    assert_response :unprocessable_entity
  end
end
