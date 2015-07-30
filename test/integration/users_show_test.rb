require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest

  def setup
    @activated_user   = users(:michael)
    @unactivated_user = users(:unactivated_user)
  end

  test "activated user should show" do
    get user_path(@activated_user)
    assert :success
  end

  test "unactivated user should not show" do
    get user_path(@unactivated_user)
    assert_redirected_to root_url
  end
end
