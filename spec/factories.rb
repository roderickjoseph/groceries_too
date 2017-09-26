FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "dummyEmail#{n}@gmail.com"
    end
    password 'secretPassword'
    password_confirmation 'secretPassword'
  end

  factory :user2, class: User do
    sequence :email do |n|
      "secondDummyEmail#{n}@gmail.com"
    end
    password 'secretPassword'
    password_confirmation 'secretPassword'
  end

  factory :list do
    association :user

    name 'list_name'
    date Time.zone.today
  end

  factory :item do
    association :user
    association :list

    name 'item_name'
  end
end
