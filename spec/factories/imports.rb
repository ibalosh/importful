FactoryBot.define do
  factory :import do
    filename { "sample.csv" }
    total_records { 1 }
    processed_records { 1 }
    not_processed_records { 0 }
  end
end
