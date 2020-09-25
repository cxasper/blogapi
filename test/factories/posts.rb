FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    published { Faker::Boolean.boolean }
    association :user, factory: :user, strategy: :build
  end

  factory :published_post, class: Post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    published { true }
    association :user, factory: :user, strategy: :build
  end
end
