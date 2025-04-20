require "test_helper"

class Api::V1::StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # ユーザーと学生を新規作成
    @user = User.create!(
      email: "student_test@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "student"
    )

    @student = Student.create!(
      user_id: @user.id,
      name: "テスト学生",
      introduce: "テスト用の自己紹介です",
      graduation_year: 2025,
      school: "テスト大学",
      portfolio_url: "https://example.com/portfolio"
    )

    # 業界とスキルを作成
    @industry1 = Industry.create!(name: "IT")
    @industry2 = Industry.create!(name: "Finance")

    @skill1 = Skill.create!(name: "Ruby on Rails")
    @skill2 = Skill.create!(name: "JavaScript")

    # 学生と業界・スキルの関連付け
    StudentIndustry.create!(student_id: @student.id, industry_id: @industry1.id)
    StudentSkill.create!(student_id: @student.id, skill_id: @skill1.id)

    # 別のユーザーと学生を作成（権限テスト用）
    @other_user = User.create!(
      email: "other_student@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "student"
    )

    @other_student = Student.create!(
      user_id: @other_user.id,
      name: "別のテスト学生",
      graduation_year: 2026
    )

    # JWTトークンを取得（ログイン）
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    @token = response.headers["Authorization"].split(" ").last

    # 別のユーザーのトークンも取得
    post user_session_path, params: {
      user: {
        email: @other_user.email,
        password: "password123"
      }
    }, as: :json

    @other_token = response.headers["Authorization"].split(" ").last
  end

  test "should get student profile" do
    get api_v1_student_path(@student), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)

    # 基本プロフィール情報の確認
    assert_equal @student.name, json_response["name"]
    assert_equal @student.introduce, json_response["introduce"]
    assert_equal @student.graduation_year, json_response["graduation_year"]

    # 業界情報の確認
    assert_not_empty json_response["industries"]
    assert_equal @industry1.id, json_response["industries"][0]["id"]
    assert_equal @industry1.name, json_response["industries"][0]["name"]

    # スキル情報の確認
    assert_not_empty json_response["skills"]
    assert_equal @skill1.id, json_response["skills"][0]["id"]
    assert_equal @skill1.name, json_response["skills"][0]["name"]
  end

  test "should get student profile without authentication" do
    get api_v1_student_path(@student), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @student.name, json_response["name"]
  end

  test "should update student profile with authentication" do
    patch api_v1_student_path(@student), params: {
      student: {
        name: "更新された名前",
        introduce: "更新された自己紹介文",
        graduation_year: 2026,
        school: "更新された大学名",
        portfolio_url: "https://updated-portfolio.example.com",
        industry_ids: [ @industry1.id, @industry2.id ],
        skill_ids: [ @skill1.id, @skill2.id ]
      }
    }, headers: { "Authorization" => "Bearer #{@token}" }, as: :json

    assert_response :success

    # プロフィールが更新されたことを確認
    @student.reload
    assert_equal "更新された名前", @student.name
    assert_equal "更新された自己紹介文", @student.introduce
    assert_equal 2026, @student.graduation_year
    assert_equal "更新された大学名", @student.school
    assert_equal "https://updated-portfolio.example.com", @student.portfolio_url

    # 業界が正しく更新されたことを確認
    assert_equal 2, @student.industries.count
    assert_includes @student.industries.map(&:id), @industry1.id
    assert_includes @student.industries.map(&:id), @industry2.id

    # スキルが正しく更新されたことを確認
    assert_equal 2, @student.skills.count
    assert_includes @student.skills.map(&:id), @skill1.id
    assert_includes @student.skills.map(&:id), @skill2.id
  end

  test "should not update student profile without authentication" do
    # 認証なしでの更新を試行
    patch api_v1_student_path(@student), params: {
      student: {
        name: "認証なしでの更新",
        introduce: "これは失敗するはず"
      }
    }, as: :json

    assert_response :unauthorized
  end

  test "should not update other student's profile" do
    # 他の学生のプロフィールを更新しようとする
    patch api_v1_student_path(@student), params: {
      student: {
        name: "別のユーザーによる更新"
      }
    }, headers: { "Authorization" => "Bearer #{@other_token}" }, as: :json

    assert_response :forbidden
    @student.reload
    assert_not_equal "別のユーザーによる更新", @student.name
  end

  test "should not update student profile with invalid data" do
    # URLバリデーションに失敗するような無効なデータで更新を試行
    patch api_v1_student_path(@student), params: {
      student: {
        portfolio_url: "invalid-url" # 無効なURLフォーマット
      }
    }, headers: { "Authorization" => "Bearer #{@token}" }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
  end

  test "should return 404 for non-existent student" do
    get api_v1_student_path(999999), as: :json
    assert_response :not_found
  end

  test "should update partial student data" do
    # 一部のフィールドのみ更新
    patch api_v1_student_path(@student), params: {
      student: {
        name: "部分更新テスト"
      }
    }, headers: { "Authorization" => "Bearer #{@token}" }, as: :json

    assert_response :success
    @student.reload
    assert_equal "部分更新テスト", @student.name
    # 他のフィールドは変わっていないことを確認
    assert_equal "テスト用の自己紹介です", @student.introduce
  end
end
