require 'test_helper'

class ZoneControllerTest < ActionController::TestCase
  test "should get list" do
    get :list
    assert_response :success
  end

  test "should get records" do
    get :records
    assert_response :success
  end

  test "should get add_record" do
    get :add_record
    assert_response :success
  end

end
