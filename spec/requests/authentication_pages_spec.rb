require 'rails_helper'
require 'spec_helper'

describe "Authentication" do

  subject {page}

  describe "signin page" do
    before{ visit signin_path }

    it{is_expected.to have_content('Sign in')}
    it{is_expected.to have_title('Sign in')}
  end#sign in page

  describe "signin" do
    before { visit signin_path}

    describe "with invalid information" do
      before {click_button "Sign in"}

      it{is_expected.to have_title('Sign in')}
      it{is_expected.to have_error_message('Invalid')}
      # it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end#after visiting another page

    end#with invalid information

    describe "with valid information" do
      let(:user){FactoryGirl.create(:user)}
      before {sign_in user}

      it {is_expected.to      have_title(user.name)}
      it {is_expected.to      have_link('Users',    href: users_path)}
      it {is_expected.to      have_link('Profile',  href: user_path(user))}
      it {is_expected.to      have_link('Settings', href: edit_user_path(user))}
      it {is_expected.to      have_link('Sign out', href: signout_path)}
      it {is_expected.not_to  have_link('Sign in',  href: signin_path)}

      describe "followed by signout" do
        before{click_link "Sign out"}
        it {is_expected.to have_link('Sign in')}
      end# followed by signout
    end#with valid information
  end# sign in

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user){FactoryGirl.create(:user)}

      #check the Log'inUser's link
      it {is_expected.not_to      have_link('Profile',  href: user_path(user))}
      it {is_expected.not_to      have_link('Settings', href: edit_user_path(user))}
      it {is_expected.not_to      have_link('Sign out', href: signout_path)}

      describe "when attempting to visit protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end#before

        describe "after signing in" do

          it "should render the desired protected page"do
            expect(page).to have_title("Edit user")
          end#shoud render the desired protected page

          describe "when signing in agein" do
            before do
              delete signout_path
              visit signin_path

              fill_in "Email", with: user.email
              fill_in "Password", with: user.password
              click_button "Sign in"
            end
            it "shoud render the default (prifuke) page" do
              expect(page).to have_title(user.name)
            end
          end# when signing in agein

          describe "in the Microposts controller" do
            describe "submitting to the destroy action" do
              before{ post microposts_path}
              specify{expect(response).to redirect_to(signin_path)}
            end
            describe "submitting to the destroy action" do
              before {delete micropost_path(FactoryGirl.create(:micropost))}
              specify{expect(response).to redirect_to(signin_path)}
            end
          end#in the Microposts controller


        end#after signing in
      end# when attempting to visit protected page


      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before {post relationships_path}
          specify{expect(response).to redirect_to(signin_path)}
        end

        describe "submmiting to the destroy action" do
          before{delete relationship_path(1)}
          specify{expect(response).to redirect_to(signin_path)}
        end
      end


      describe "in the Users controller" do

        describe "visiting the edit page" do
          before{visit edit_user_path(user)}
          it {is_expected.to have_title('Sign in')}

          describe "submitting to the update action" do
            before{patch user_path(user)}
            specify{expect(response).to redirect_to(signin_path)}
          end
        end#visiting the edit page

        describe "visiting the user index" do
          before{visit users_path}
          it{is_expected.to have_title('Sign in')}
        end#visiting the user index


        describe "visiting the following page" do
          before {visit following_user_path(user)}
          it{is_expected.to have_title('Sign in')}
        end

        describe "visiting the followers page" do
          before{ visit followers_user_path(user)}
          it{is_expected.to have_title('Sign in')}
        end


      end#in the Users controller
    end#for non signed in users

    describe "as wrong user" do
      let(:user){FactoryGirl.create(:user)}
      let(:wrong_user){FactoryGirl.create(:user, email: "wrong@example.com")}
      before{sign_in user,no_capybara: true}

      describe "submitting a GET request to the User#edit action" do
        before{get edit_user_path(wrong_user)}
        specify{expect(response.body).not_to match(full_title('Edit user'))}
        specify{expect(response).to redirect_to(root_url)}
      end

      describe "submitting a PATCH request to the Users#update action" do
        before{patch user_path(wrong_user)}
        specify{expect(response).to redirect_to(root_path)}
      end
    end#as wrong user

    describe "as non-admin user" do
        let(:user){FactoryGirl.create(:user)}
        let(:non_admin){FactoryGirl.create(:user)}

        before{sign_in non_admin, no_capybara: true}

        describe "submitting a DELETE request to User#destroy action" do
          before{delete user_path(user)}
          specify{expect(response).to redirect_to(root_path)}
        end
      end


  end# authorization
end