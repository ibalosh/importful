FactoryBot.define do
  factory :import do
    status { "MyString" }
    filename { "MyString" }
    total_records { 1 }
    processed_records { 1 }
    not_processed_records { 1 }
  end
end
