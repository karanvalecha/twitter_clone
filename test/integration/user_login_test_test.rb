require 'test_helper'

class UserLoginTestTest < ActionDispatch::IntegrationTest
  def setup
  	@user = users(:karan)
  end

  test "Invalid Login" do
  	get login_path
  	assert_template 'sessions/new'
  	post login_path, session: { password: "", email: "" }
  	assert_template 'sessions/new'
  	assert_not flash.empty?
  	get root_path
  	assert_not flash.empty?
  end

  test "Valid login with logout" do
  	get login_path
  	assert_template 'sessions/new'
  	post login_path, session: { email: @user.email, password: 'password', remember_me: '0' }
  	assert is_logged_in?
  	assert_redirected_to @user
  	follow_redirect!
  	assert_template 'users/show'
  	assert_not flash.empty?
  	assert_select "a[href=?]", login_path, count: 0
  	assert_select "a[href=?]", logout_path
  	assert_select "a[href=?]", user_path(@user)
  	delete logout_path
  	assert_not is_logged_in?
  	assert_redirected_to root_url
  	follow_redirect!
  	assert_select "a[href=?]", login_path
  	assert_select "a[href=?]", logout_path, count: 0
  	assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_nil cookies['remember_token']
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end
end