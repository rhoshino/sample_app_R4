require 'rails_helper'

describe Relationship do

  let(:follower){FactoryGirl.create(:user)}
  let(:followed){FactoryGirl.create(:user)}
  let(:relationship){follower.relationships.build(followed_id: followed.id)}


  subject{ relationship }


  it {is_expected.to be_valid}

  describe "follower method" do
    it {is_expected.to respond_to(:follower)}
    it {is_expected.to respond_to(:followed)}

    it {
      # binding.pry
      expect(subject.follower).to eq follower}
    it {
      # binding.pry
      expect(subject.followed).to eq followed}
  end# follower method

  describe "when followed_id is not present" do
    before { relationship.followed_id = nil}
    it{ is_expected.not_to be_valid}
  end

  describe "when follower_id is not present"do
    before { relationship.follower_id = nil}
    it{ is_expected.not_to be_valid}
  end


end
