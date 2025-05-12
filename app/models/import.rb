class Import < ApplicationRecord
  belongs_to :merchant
  has_one_attached :file, dependent: :destroy
  has_many :import_details, dependent: :destroy
  include OwnedByMerchant

  STATUSES = %w[pending processing finished failed].freeze
  enum :status, STATUSES.index_by(&:to_sym)

  attribute :status, :string, default: "pending"

  # Dynamically define status check methods
  STATUSES.each do |status_name|
    define_method("#{status_name}?") do
      status == status_name
    end
  end
end
