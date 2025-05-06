class Merchant < ApplicationRecord
  has_many :affiliates

  has_secure_password

  validates :slug,
    presence: true,
    uniqueness: true,
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\Z/ }
end
