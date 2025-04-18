require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  test "should get create_with_cruiter" do
    get companies_create_with_cruiter_url
    assert_response :success
  end
end
