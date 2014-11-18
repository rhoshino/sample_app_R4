require 'rails_helper'
require 'spec_helper'


describe "User pages" do

  subject{ page }

  describe "profile page" do
    let(:user){FactoryGirl.create(:user)}
    before { visit user_path(user)}

    it {is_expected.to have_content(user.name)}
    it {is_expected.to have_title(user.name)}
  end


  describe "signup page" do
    before { visit signup_path }

    it{is_expected.to have_content('Sign up')}
    it{is_expected.to have_title(full_title('Sign up'))}
  end

  describe "signup" do
    before {visit signup_path}

    let(:submit){"Create my account"}

    describe "with invalid information" do
      it "shoud not create a user" do
        expect{click_button submit}.not_to change(User, :count)
      end

      describe "after submission" do
        before {click_button submit}

        it{ is_expected.to have_title('Sign up')}
        it{ is_expected.to have_content('error')}
      end
    end# sign up with invalid information

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect{click_button submit}.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before{click_button submit}
        let(:user){ User.find_by(email: 'user@example.com')}

        it {is_expected.to have_link('Sign out')}
        it {is_expected.to have_title(user.name)}
        it {is_expected.to have_selector('div.alert.alert-success', text:'Welcome')}
      end

    end#sign up with valid information
  end# sign up

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it {is_expected.to have_content('Update your profile')}
      it {is_expected.to have_title("Edit user")}
      it {is_expected.to have_link('change', href:'http://gravatar.com/emails')}
    end# edit page

    describe "with invalid information" do

      before{click_button "Save changes"}
      it{is_expected.to have_content('error')}
    end# edit with invalid ingormation


    describe "with valid information" do

      let(:new_name){"New Name"}
      let(:new_email){"new@example.com"}
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it {is_expected.to have_title(new_name)}
      it {is_expected.to have_selector('div.alert.alert-success')}
      it {is_expected.to have_link('Sign out')}

      specify{expect(user.reload.name).to eq new_name}
      specify{expect(user.reload.email).to eq new_email}

    end#edit with calid information

  end# edit

end#user pages
