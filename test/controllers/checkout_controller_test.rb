require "test_helper"

class CheckoutControllerTest < ActionDispatch::IntegrationTest
  test "should get address" do
    get checkout_address_url
    assert_response :success
  end

  test "should get summary" do
    get checkout_summary_url
    assert_response :success
  end

  test "should get create" do
    get checkout_create_url
    assert_response :success
  end
end
