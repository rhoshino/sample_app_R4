#coding:utf-8


require 'rails_helper'
require 'spec_helper'

describe "Apprication Helper" do
  describe "full_title" do
    it "include the page title" do
      expect(full_title("foo")).to match(/foo/)
    end

    it "include the base title" do
      expect(full_title("foo")).to match(/^Ruby on Rails Tutorial Sample App/)
    end

    it "shoud not include a bar for the home page"do
      expect(full_title("")).not_to match(/\|/)
    end
  end
end