require 'rails_helper'

describe "StatricPages" do

	let(:base_title){ "Ruby on Rails Tutorial Sample App | " }

  describe "GET /static_pages (Homepage)" do
		it "Have content 'Sample'" do
		  visit '/static_pages/home'
		  expect(page).to have_content ('Sample App')
		end

		it "Have the right title" do
			visit '/static_pages/home'
			expect(page).to have_title("#{base_title}Home")
		end
  end

  describe "Help page" do
  	it "Have content 'Help'" do
  		visit '/static_pages/help'
  		expect(page).to have_content ('Help')
  	end


  	it "Have the right title" do
			visit '/static_pages/help'
			expect(page).to have_title("#{base_title}Help")
		end
  end

  describe "About page" do
  	it "Have content 'about'" do
  		visit '/static_pages/about'
  		expect(page).to have_content ('About Us')
  	end

		it "Have the right title" do
			visit '/static_pages/about'
			expect(page).to have_title("#{base_title}About")
		end
  end

  describe "Contact page" do
  	it "Have content 'Contact'" do
  		visit '/static_pages/contact'
  		expect(page).to have_content ('Contact')
  	end

		it "Have the right title" do
			visit '/static_pages/contact'
			expect(page).to have_title("#{base_title}Contact")
		end

  end





end
