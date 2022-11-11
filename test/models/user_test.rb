require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name: "example", email: "example@user.com")
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
end