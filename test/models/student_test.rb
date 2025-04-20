require "test_helper"

class StudentTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test_student@example.com",
      password: "password",
      password_confirmation: "password",
      role: "student"
    )
  end

  test "should be valid with all required attributes" do
    student = Student.new(
      user: @user,
      name: "テスト学生"
    )
    assert student.valid?, "Student with all required attributes should be valid"
  end

  test "should not be valid without a name" do
    student = Student.new(
      user: @user,
      name: nil
    )
    assert_not student.valid?, "Student should not be valid without a name"
    assert_includes student.errors[:name], "can't be blank"
  end

  test "should not be valid without a user" do
    student = Student.new(
      name: "テスト学生"
    )
    assert_not student.valid?, "Student should not be valid without a user"
  end

  test "user_id should be the primary key" do
    student = Student.create!(
      user: @user,
      name: "テスト学生"
    )

    # user_idがプライマリーキーとして使用されていることを確認
    assert_equal @user.id, student.id
    assert_equal @user.id, student.user_id
  end

  test "should not allow duplicate user_id" do
    # 最初の学生レコードを作成
    Student.create!(
      user: @user,
      name: "テスト学生"
    )

    # 別のユーザーを作成
    another_user = User.create!(
      email: "another_student@example.com",
      password: "password",
      password_confirmation: "password",
      role: "student"
    )

    # 同じユーザーで2つ目のレコードを作成しようとする
    duplicate_student = Student.new(
      user: @user,  # 同じユーザー
      name: "別の学生"
    )

    assert_not duplicate_student.valid?, "Should not allow duplicate user_id"
    assert_includes duplicate_student.errors[:user_id], "has already been taken"
  end

  test "should validate portfolio_url format" do
    # 有効なURL
    valid_student = Student.new(
      user: @user,
      name: "テスト学生",
      portfolio_url: "https://example.com"
    )
    assert valid_student.valid?, "Student with valid portfolio_url should be valid"

    # 無効なURL
    invalid_student = Student.new(
      user: @user,
      name: "テスト学生",
      portfolio_url: "invalid-url"
    )
    assert_not invalid_student.valid?, "Student with invalid portfolio_url should not be valid"
    assert_includes invalid_student.errors[:portfolio_url], "is invalid"
  end

  test "should allow nil portfolio_url" do
    student = Student.new(
      user: @user,
      name: "テスト学生",
      portfolio_url: nil
    )
    assert student.valid?, "Student with nil portfolio_url should be valid"
  end

  test "should be destroyed when user is destroyed" do
    student = Student.create!(
      user: @user,
      name: "テスト学生"
    )

    assert_difference("Student.count", -1) do
      @user.destroy
    end
  end
end
