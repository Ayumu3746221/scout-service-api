require "test_helper"

class RecruitersControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get recruiters_create_url
    assert_response :success
  end
end
