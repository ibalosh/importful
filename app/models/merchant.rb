class Merchant < ApplicationRecord
  has_many :affiliates
  has_many :imports
  has_secure_password

  enum :role, { regular: "regular", admin:   "admin" }
  validates :role, inclusion: { in: roles.keys }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\Z/ }

  # returns a `{ slug => id }` hash of the merchants this user can see
  def self.slug_id_map_for(merchant)
    merchant = merchant.admin? ? all : where(id: merchant.id)
    merchant.pluck(:slug, :id).to_h
  end
end
