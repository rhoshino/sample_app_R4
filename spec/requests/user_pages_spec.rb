require 'rails_helper'
require 'spec_helper'


describe "User pages" do

  subject{ page }


  describe "index" do

    let(:user){FactoryGirl.create(:user)}

    before (:each) do
      sign_in user
      visit users_path
    end

    it{is_expected.to have_title('All users')}
    it{is_expected.to have_content('All users')}

    describe "pagination" do
      before(:all){30.times{FactoryGirl.create(:user)}}
      after(:all){User.delete_all}

      it{ is_expected.to have_selector('div.pagination')}

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end

    end

    describe "delete links" do
      it {is_expected.not_to have_link('delete')}

      describe "as an admin user" do
        let(:admin){FactoryGirl.create(:admin)}

        before do
          sign_in admin
          visit users_path
        end

        it {is_expected.to have_link('delete',href: user_path(User.first))}

        it"should be able to delete another user" do
          expect do
            click_link('delete',match: :first)
          end.to change(User, :count).by(-1)
        end

        it{is_expected.not_to have_link('delete', href: user_path(admin))}

      end#as an admin user
    end#delete links


    it "should list each user"do
      User.all.each do |user|
        expect(page).to have_selector('li',text:user.name)
      end
    end
  end# index page


  describe "profile page" do
    let(:user){FactoryGirl.create(:user)}
    let!(:m1){FactoryGirl.create(:micropost, user: user, content: "Foo")}
    let!(:m2){FactoryGirl.create(:micropost, user: user, content: "Bar")}

    before { visit user_path(user)}

    it {is_expected.to have_content(user.name)}
    it {is_expected.to have_title(user.name)}


    describe "microposts" do
      it{is_expected.to have_content(m1.content)}
      it{is_expected.to have_content(m2.content)}
      it{is_expected.to have_content(user.microposts.count)}
    end


    describe "follow/unfollow buttons" do
      let(:other_user){FactoryGirl.create(:user)}
      before{sign_in user}

      describe "followiing a user" do
        before {visit user_path(other_user)}

        it "should increment the followed user count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end
        it "shoud increment the other yser's followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "togging the button" do
          before{click_button "Follow"}
          it{ is_expected.to have_xpath("//input[@value='Unfollow']")}
        end

        describe "unfollowing a user" do
          before do
            user.follow!(other_user)
            visit user_path(other_user)
          end

          it "shoud decrement the followed user count"do
            expect do
              click_button "Unfollow"
            end.to change(user.followed_users, :count).by(-1)
          end
          it "shoud decrement the other yser's followers count" do
            expect do
              click_button "Unfollow"
            end.to change(other_user.followers, :count).by(-1)
          end

          describe "togging the button" do
            before{click_button "Unfollow"}
            it{is_expected.to have_xpath("//input[@value='Follow']")}
          end

        end# unfollowing
      end# following user
    end#Follow / Unollow
  end#profile page


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
        fill_in "Confirm Password", with: "foobar"
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

    describe "forbidden attributeds" do
      let(:params)do# this parametters send!
        {user: {admin: true,
                password: user.password,
                password_confirmation: user.password}}
      end

      before do
        sign_in user, no_capybara: true
        patch user_path(user), params# direct requesting to admin
      end

      specify{expect(user.reload).not_to be_admin}

    end

  end# edit

  describe "following/followers" do
    let(:user){FactoryGirl.create(:user)}
    let(:other_user){FactoryGirl.create(:user)}
    before{user.follow!(other_user)}

    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it {is_expected.to have_title(full_title('Following'))}
      it {is_expected.to have_selector('h3', text: 'Following')}
      it {is_expected.to have_link(other_user.name, href: user_path(other_user))}

    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it {is_expected.to have_title(full_title('Followers'))}
      it {is_expected.to have_selector('h3', text: 'Followers')}
      it {is_expected.to have_link(user.name, href: user_path(user))}

    end

  end#following/followers

end#user pages
