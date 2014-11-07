require 'rails_helper'
require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "signup page" do
    before {visit signup_path}

    it {is_expected.to have_content('Sign up')}
    it {is_expected.to have_title(full_title('Sign up'))}

  end

end
