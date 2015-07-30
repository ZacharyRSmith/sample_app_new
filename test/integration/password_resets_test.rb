require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear

    @user = users(:michael)
  end

  test "user should be able to reset password" do
    # FIXME Get new path
    get new_password_reset_path
    assert_template 'password_resets/new'

    # Invalid email
    post password_resets_path, password_reset: { email: '' }
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # User gets new password reset email:
    post password_resets_path, password_reset: { email: @user.email }
    assert_not_equal @user.password_reset_digest,
                     @user.reload.password_reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    user = assigns(:user)

    # Inactive user:
    user.toggle!(:activated)
    get edit_password_reset_path(user.password_reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)

    # New password page doesn't render with incorrect token:
    get edit_password_reset_path('iGonnaHackU', email: user.email)
    assert_redirected_to root_url

    # New password page doesn't render with incorrect email:
    get edit_password_reset_path(user.password_reset_token,
                                 email: 'BigMama@bellsouth.net')
    assert_redirected_to root_url

    # New password page renders with correct token and email:
    get edit_password_reset_path(user.password_reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # New password is not created if passwords are empty:
    patch password_reset_path(user.password_reset_token),
        email: user.email,
        user: { password: '',
                password_confirmation: '' }
    assert_not flash.empty?

    # New password is not created if confirmation doesn't match password:
    patch password_reset_path(user.password_reset_token),
        email: user.email,
        user: { password: 'new_password',
                password_confirmation: 'WHOOPS' }
    assert_select 'div#error_explanation'

    # New password is created if it passes validations:
    patch password_reset_path(user.password_reset_token),
        email: user.email,
        user: { password: 'new_password',
                password_confirmation: 'new_password' }
#     user = assigns(:user)
#     user.reload
    
#     assert_equal User.digest("new_password"), User.digest("new_password")
#     assert_equal User.digest('new_password'), user.password_digest
    assert_not flash.empty?
    assert_redirected_to user

#     # User is automatically logged-in after resetting password:
    assert is_logged_in?
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path, password_reset: { email: @user.email }

    @user = assigns(:user)
    @user.update_attribute(:password_reset_sent_at, 100.years.ago)
    patch password_reset_path(@user.password_reset_token),
        email: @user.email,
        user: { password: 'new_password',
                password_confirmation: 'new_password' }
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end
end
