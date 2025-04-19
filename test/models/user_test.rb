require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user without email" do
    user = User.new(password: "password", password_confirmation: "password", role: "student")
    assert_not user.save, "Saved the user without an email"
  end

  test "should set student role by default" do
    user = User.new(email: "test@example.com", password: "password", password_confirmation: "password")
    assert user.save, "Could not save user with default role"
    assert_equal "student", user.role, "Default role should be 'student'"
  end

  test "should save valid user" do
    user = User.new(
      email: "valid@example.com",
      password: "password",
      password_confirmation: "password",
      role: "student"
    )
    assert user.save, "Could not save valid user"
  end

  test "should have correct jwt_payload for student" do
    user = User.create(
      email: "student@example.com",
      password: "password",
      password_confirmation: "password",
      role: "student"
    )

    assert_empty user.jwt_payload, "Student should have empty jwt_payload"
  end
end
