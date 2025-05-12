module OwnedByMerchant
  extend ActiveSupport::Concern

  included do
    scope :for_merchant, ->(user) { user.admin? ? all : where(merchant_id: user.id) }
  end
end
