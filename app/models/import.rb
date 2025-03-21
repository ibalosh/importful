class Import < ApplicationRecord
  has_one_attached :file

  STATUSES = %w[pending processing finished failed].freeze
  enum :status, STATUSES.index_by(&:to_sym)

  attribute :status, :string, default: "pending"
end
