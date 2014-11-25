require 'rails_helper'
require 'spec_helper'


describe RelationshipsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before {sign_in user, no_capybara: true}

  describe "creating a relationship with Ajax" do

    it "shoud increment the Relationship count"do
      expect do
        xhr :post, :create, relationship:{followed_id: other_user.id}
      end.to change(Relationship, :count).by(1)
    end

    it "shoud respond with success" do
      xhr :post, :create, relationship: { followed_id: other_user.id }
      expect(response.status).to eq(200)# status check
      #"expect(response),to be balid" is realy collect
    end
  end

  describe "destroying a relationship with Ajax" do
    before { user.follow!(other_user) }
    let(:relationship){user.relationships.find_by_followed_id(other_user)}
    it "shoud decrement the Relationship count" do
      expect do
        xhr :delete, :destroy, id: relationship.id
      end.to change(Relationship, :count).by(-1)
    end

    it "shoud respond with success"do
      xhr :delete, :destroy, id:relationship.id
      expect(response).to be_success
    end
  end



end
