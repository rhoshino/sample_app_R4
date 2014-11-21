require 'rails_helper'

#coding:utf-8
describe User do
  before do
    @user = User.new(name: "Example",
                     email: "user@example.com",
                     password: "foobar",
                     password_confirmation: "foobar")
  end

  subject {@user}

  # Columns Chacck
  it {is_expected.to respond_to(:email)}
  it {is_expected.to respond_to(:name)}
  it {is_expected.to respond_to(:password_digest)}
  it {is_expected.to respond_to(:password)}
  it {is_expected.to respond_to(:password_confirmation)}
  it {is_expected.to respond_to(:remember_token)}
  it {is_expected.to respond_to(:authenticate)}
  it {is_expected.to respond_to(:admin)}
  #relation to micropost
  it {is_expected.to respond_to(:microposts)}
  it {is_expected.to respond_to(:feed)}
  #relation ships to followed follower
  it {is_expected.to respond_to(:relationships)}
  it {is_expected.to respond_to(:followed_users)}
  it {is_expected.to respond_to(:following?)}
  it {is_expected.to respond_to(:follow!)}
  it {is_expected.to respond_to(:followers)}

  #Validated?
  it {is_expected.to be_valid}
  it {is_expected.not_to be_admin}

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it{is_expected.to be_admin}
  end

  describe "When name is not present" do
    before{@user.name = " "}
    #バリデーションされ、失敗するか
    it{is_expected.not_to be_valid}
  end

  describe "When email is not present" do
    before{@user.email = " "}
    #バリデーションされ、失敗するか
    it{is_expected.not_to be_valid}
  end

  describe "when name is too long" do
    before{@user.name = "a" * 51}
    it{is_expected.not_to be_valid}
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com
                    user_at_foo.org
                    example.user@foo.
                    foo@bar_baz.com
                    foo@bar+baz.com
                    foo@bar..com]
      addresses.each do |invalid_address|

        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM
                      A_US-ER@f.b.org
                      frst.lst@foo.jp
                      a+b@baz.cn]

      addresses.each do |valid_address|

        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it{ is_expected.not_to be_valid }
  end

  describe "email address with mixed case" do
    let(:mixed_case_email){"Foo@ExAMPle.CoM"}

    it "should be saved as all lower-case " do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "when password is not present" do
    before do
      @user =  User.new(name: "Example User",
                        email: "user@example.com",
                        password: " ",
                        password_confirmation: " ")
    end

    it {is_expected.not_to be_valid}
  end


  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it{ is_expected.not_to be_valid}
  end

  describe "with a password that's too short" do
    before {@user.password = @user.password_confirmation = "a" * 5 }
    it{is_expected.to be_invalid}
  end

 describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      # it { is_expected.to eq found_user.authenticate(@user)}
      it { is_expected.to eq(found_user.authenticate(@user.password))}

    end

    describe "with incalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid")}

      it { is_expected.not_to eq user_for_invalid_password}
      specify { expect(user_for_invalid_password).to be_falsey}
    end

  end

  describe "remember token" do
    before{@user.save}
    it(:remember_token){is_expected.not_to be_blank}
  end

  describe "micropost associations" do
    before {@user.save}

    let!(:older_micropost)do
      FactoryGirl.create(:micropost,user: @user,created_at: 1.day.ago)
    end
    let!(:newer_micropost)do
      FactoryGirl.create(:micropost,user: @user,created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "should destroy associated microposts"do
      microposts = @user.microposts.dup.to_a
      @user.destroy

      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end
    describe "status" do
      let(:unfollowrd_post)do
        FactoryGirl.create(:micropost, user:FactoryGirl.create(:user))
      end

      it {expect(subject.feed).to include(newer_micropost)}
      it {expect(subject.feed).to include(older_micropost)}
      it {expect(subject.feed).not_to include(unfollowrd_post)}

    end

  end#micropost assciations


  describe "following" do
    let(:other_user){FactoryGirl.create(:user)}

    before do
      @user.save
      @user.follow!(other_user)
    end

    it{ is_expected.to be_following(other_user) }
    it{ expect(subject.followed_users).to include(other_user)}

    describe "following" do
      subject{other_user}
      it{expect(subject.followers).to include(@user)}
    end


    describe "and unfollowing(remove)" do
      before { @user.unfollow!(other_user)}

      it{ is_expected.not_to be_following(other_user)}
      it{ expect(subject.followed_users).not_to include(other_user)}
    end

  end# following


end  # Describe user
