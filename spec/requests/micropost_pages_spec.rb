require 'rails_helper'

describe "MicropostPages" do

  subject{ page }

  let(:user){ FactoryGirl.create(:user) }
  before{ sign_in user}

  describe "micropost creation" do
    before{ visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect{click_button "Post"}.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post"}
        it { is_expected.to have_content('error')}
      end
    end# with invalid information

    describe "with valid information" do
      before {fill_in 'micropost_content', with: "Lolem ipsum"}
      it "shoud create a micropost"do
        expect {click_button "Post"}.to change(Micropost, :count).by(1)
      end

      describe "and post 1 micropost" do
        before{ click_button "Post"}

        it{is_expected.to have_content('1 micropost')}
        it{is_expected.not_to have_content('1 microposts')}
      end

      describe "and post 2 microposts" do
        before{ click_button "Post"
                fill_in 'micropost_content', with: "Lolem ipsum"
                click_button "Post"}

        it{is_expected.to have_content('2 microposts')}
      end
    end#with valid information

    describe "pagination" do
      before do
        40.times{FactoryGirl.create(:micropost,user: user)}
        visit root_path
      end
      after{Micropost.delete_all}

      it{is_expected.to have_selector('div.pagination')}

      it"shoud list each micropost"do
        user.microposts.paginate(page: 1).each do |micropost|
          expect(page).to have_selector('li', text: micropost.content)
        end
      end
    end


  end# micropost creation

  describe "micropost destruction" do
    before {FactoryGirl.create(:micropost, user: user) }

    before{visit root_path}

    it "should delete a micropost" do
      expect{click_link "delete"}.to change(Micropost, :count).by(-1)
    end
  end# micrppost destruction

end
