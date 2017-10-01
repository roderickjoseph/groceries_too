FactoryGirl.define do
  factory :user do

    sequence :email do |n|
      "dummyEmail#{n}@gmail.com"
    end
    password 'secretPassword'
    password_confirmation 'secretPassword'
  end

  factory :list do
    association :user

    name 'list_name'
    date Time.zone.today

    trait :with_items do
      association :user
      after(:create) do |list|
        create_list(:item, 3, list: list, user: list.user)
      end
    end

    # after(:create) do |list, evaluator|
    #   create_list(:list, evaluator.item_count, list: list)
    # end
  end

  factory :item do
    association :user
    association :list

    name 'item_name'
  end
end
