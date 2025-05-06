require "test_helper"

class Api::V1::MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    # 業界と企業の作成
    @industry = Industry.create!(name: "IT")
    @company = Company.create!(
      name: "テスト株式会社",
      email: "company@example.com",
      industry: @industry
    )

    # 採用担当者ユーザーと関連レコードの作成
    @recruiter_user = User.create!(
      email: "recruiter@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "recruiter"
    )

    @recruiter = Recruiter.create!(
      user: @recruiter_user,
      company: @company,
      name: "採用担当者"
    )

    # 学生ユーザーと関連レコードの作成
    @student_user = User.create!(
      email: "student@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "student"
    )

    @student = Student.create!(
      user: @student_user,
      name: "テスト学生"
    )

    # 別の学生と採用担当者を作成（パートナー一覧テスト用）
    @another_recruiter_user = User.create!(
      email: "another_recruiter@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "recruiter"
    )

    @another_company = Company.create!(
      name: "別のテスト株式会社",
      email: "another_company@example.com",
      industry: @industry
    )

    @another_recruiter = Recruiter.create!(
      user: @another_recruiter_user,
      company: @another_company,
      name: "別の採用担当者"
    )

    # JWT認証トークン取得（学生）
    post user_session_path, params: {
      user: {
        email: @student_user.email,
        password: "password123"
      }
    }, as: :json

    @student_token = response.headers["Authorization"].split(" ").last

    # JWT認証トークン取得（採用担当者）
    post user_session_path, params: {
      user: {
        email: @recruiter_user.email,
        password: "password123"
      }
    }, as: :json

    @recruiter_token = response.headers["Authorization"].split(" ").last

    # メッセージをいくつか作成
    @message1 = Message.create!(
      sender: @student_user,
      receiver: @recruiter_user,
      content: "こんにちは、興味があります"
    )

    @message2 = Message.create!(
      sender: @recruiter_user,
      receiver: @student_user,
      content: "ご連絡ありがとうございます"
    )

    @message3 = Message.create!(
      sender: @student_user,
      receiver: @another_recruiter_user,
      content: "別の採用担当者へのメッセージ"
    )
  end

  test "should create message with valid data" do
    assert_difference("Message.count") do
      post api_v1_messages_path, params: {
        message: {
          receiver_id: @recruiter_user.id,
          content: "新しいメッセージ"
        }
      },
      headers: { "Authorization" => "Bearer #{@student_token}" },
      as: :json
    end

    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "Message sent successfully", json_response["message"]
    assert_equal "新しいメッセージ", json_response["content"]["content"]
    assert_equal @student_user.id, json_response["content"]["sender"]["id"]
    assert_equal @recruiter_user.id, json_response["content"]["receiver"]["id"]
  end

  test "should not create message without authentication" do
    assert_no_difference("Message.count") do
      post api_v1_messages_path, params: {
        message: {
          receiver_id: @recruiter_user.id,
          content: "認証なしのメッセージ"
        }
      }, as: :json
    end

    assert_response :unauthorized
  end

  test "should not create message with invalid data" do
    assert_no_difference("Message.count") do
      post api_v1_messages_path, params: {
        message: {
          receiver_id: @recruiter_user.id,
          content: ""  # 空のコンテンツ
        }
      },
      headers: { "Authorization" => "Bearer #{@student_token}" },
      as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Content can't be blank"
  end

  test "should not create message between same role users" do
    # 別の学生を作成
    another_student_user = User.create!(
      email: "another_student@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "student"
    )

    assert_no_difference("Message.count") do
      post api_v1_messages_path, params: {
        message: {
          receiver_id: another_student_user.id,
          content: "同じロール同士のメッセージ"
        }
      },
      headers: { "Authorization" => "Bearer #{@student_token}" },
      as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "must be different roles"
  end

  test "should get partners list" do
    get partners_api_v1_messages_path,
        headers: { "Authorization" => "Bearer #{@student_token}" },
        as: :json

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 2, json_response["partners"].length

    # パートナーリストに正しいユーザーが含まれているか確認
    partner_ids = json_response["partners"].map { |p| p["id"] }
    assert_includes partner_ids, @recruiter_user.id
    assert_includes partner_ids, @another_recruiter_user.id

    # 企業名が含まれているか確認
    recruiter_partner = json_response["partners"].find { |p| p["id"] == @recruiter_user.id }
    assert_equal @company.name, recruiter_partner["company_name"]
  end

  test "should not get partners list without authentication" do
    get partners_api_v1_messages_path, as: :json
    assert_response :unauthorized
  end

  test "should return empty array when user has no messages" do
    # 新しいユーザーを作成（メッセージ履歴なし）
    new_user = User.create!(
      email: "new_student@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "student"
    )

    Student.create!(
      user: new_user,
      name: "新規学生"
    )

    # 新しいユーザーでログイン
    post user_session_path, params: {
      user: {
        email: new_user.email,
        password: "password123"
      }
    }, as: :json

    new_token = response.headers["Authorization"].split(" ").last

    # パートナー一覧を取得
    get partners_api_v1_messages_path,
        headers: { "Authorization" => "Bearer #{new_token}" },
        as: :json

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_empty json_response["partners"]
  end
end
