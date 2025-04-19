require "test_helper"

class JwtDenylistTest < ActiveSupport::TestCase
  test "should create a valid jwt denylist entry" do
    jwt_denylist = JwtDenylist.new(
      jti: "test_jti_token",
      exp: 1.day.from_now
    )
    assert jwt_denylist.valid?, "JwtDenylist entry with jti and exp should be valid"
  end

  test "should not be valid without a jti" do
    jwt_denylist = JwtDenylist.new(exp: 1.day.from_now)
    assert_not jwt_denylist.valid?, "JwtDenylist entry should not be valid without a jti"
    assert_includes jwt_denylist.errors[:jti], "can't be blank"
  end

  test "should not be valid without an exp" do
    jwt_denylist = JwtDenylist.new(jti: "test_jti_token")
    assert_not jwt_denylist.valid?, "JwtDenylist entry should not be valid without an exp"
    assert_includes jwt_denylist.errors[:exp], "can't be blank"
  end

  test "should not allow duplicate jti" do
    JwtDenylist.create!(
      jti: "test_jti_token",
      exp: 1.day.from_now
    )

    duplicate_jwt = JwtDenylist.new(
      jti: "test_jti_token",
      exp: 2.days.from_now
    )

    assert_not duplicate_jwt.valid?, "Should not allow duplicate jti"
    assert_includes duplicate_jwt.errors[:jti], "has already been taken"
  end
end
