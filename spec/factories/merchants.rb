FactoryBot.define do
  factory :merchant do
    slug { Faker::Company.unique.name.parameterize }
    password_digest { BCrypt::Password.create("test") }
    password { "test" }
  end
end
