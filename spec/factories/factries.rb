#coding:utf-8

FactoryGirl.define do
  factory :user do
    name "Michel Hartl"
    email "micheal@example.com"
    password "foobar"
    password_confirmation "foobar"

  end
end