require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name: "example", email: "example@user.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
    #assert_not @user.name.empty?
  end

  test "name should not be empty" do
    @user.name  = ""
    assert_not @user.valid?
  end

  test "email should not be empty" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "should not be to long" do
    @user.name = "a"*51
    assert_not @user.valid?
  end

  test "should email not be too long" do
    @user.email = "a"*248+"@mail.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid adresses" do
    valid_adresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                        first.last@foo.jp alice+bob@baz.cn]
    valid_adresses.each do |valid_adress|
      @user.email = valid_adress
      assert @user.valid?, "#{valid_adress} shoud be valid"
    end
  end

  test "email validation should reject invalid adresses" do
    invalid_adresses = %w[user@example,com user_at_foo.org user.name@example.
                          foo@bar_baz.com foo@bar+baz.com toto@mail..com]
    invalid_adresses.each do |invalid_adress|
      @user.email = invalid_adress
      assert_not @user.valid?, "#{invalid_adress.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    #duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ispum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
    # Users can't follow themselves.
    michael.follow(michael)
    assert_not michael.following?(michael)
  end

  test "feed should have the right posts" do
    michael = users(:michael)
    archer = users(:archer)
    lana = users(:lana)
    # Post from followed user
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end
    # Self-posts for user with followers
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    # Post from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end
