require 'rails_helper'

#coding:utf-8
describe User do
  before {@user = User.new(name: "Example",
                            email: "user@example.com")}
  subject {@user}

  it {is_expected.to respond_to(:email)}
  it {is_expected.to respond_to(:name)}

  it {is_expected.to be_valid}

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



end
