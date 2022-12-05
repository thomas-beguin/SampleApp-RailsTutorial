require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test "layout links" do
    #Get the root path (Home page).
    get root_path

    #Verify that the right page template is rendered.
    assert_template 'static_pages/home'

    #Check for the correct links to the Home, Help, About, and Contact pages.
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", login_path
    user = users(:michael)
    log_in_as(user)
    get root_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(user)
    assert_select "a[href=?]", edit_user_path(user)
    assert_select "a[href=?]", logout_path

    #Rails inserts the path in place of the question mark, and checks if there
    #is an HTML tag of the form <a href="">...<a/>
    get contact_path
    assert_select "title", full_title("Contact")

    get signup_path
    assert_select "title", full_title("Sign up")
  end
end
