require 'rails_helper'

describe "Authentication" do

  subject {page}

  describe "signin page" do
    before{ visit signin_path }

    it{is_expected.to have_selector('h1', text:'Sign in')}
    it{is_expected.to have_selector('title', text:'Sign in')}

  end
end
