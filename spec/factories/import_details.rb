FactoryBot.define do
  factory :import_detail do
    import { nil }
    row_number { 1 }
    error_messages { "MyText" }
  end
end
