require 'rails_helper'

describe "Authentication" do

  subject {page}

  describe "signin page" do
    before{ visit signin_path }

    it{is_expected.to have_selector('h1', text:'Sign in')}
    it{is_expected.to have_selector('title', text:'Sign in')}


    describe "with invalid information" do
      before {click_button "Sign in"}

      it{is_expected.to have_selector('title', text: 'Sign in')}
      it{is_expected.to have_selector('div.alert.alert-error', text:'Invarid')}

      describe "after visiting another page" do
        before{click_link "Home"}
        it{is_expected.not_to have_selector('div.alert.alert-error')}
      end

    end

    describe "with valid information" do
      let(:user){FactoryGirl.create(:user)}

      before do
        fill_in "Email", with: user.email.upcase
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it {is_expected.to have_selector('title', text: user.name)}
      it {is_expected.to have_link('Profile', href: user_path(user))}
      it {is_expected.to have_link('Sign out', href: signout_path)}
      it {is_expected.not_to have_link('Sign in', href: signin_path)}

    end



  end
end
