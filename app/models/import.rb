class Import < ApplicationRecord
  belongs_to :merchant
  has_one_attached :file, dependent: :destroy
  has_many :import_details, dependent: :destroy
  include OwnedByMerchant

  STATUSES = %w[pending processing finished failed].freeze
  enum :status, STATUSES.index_by(&:to_sym)

  attribute :status, :string, default: "pending"

  # only broadcast when the status column was updated
  after_update_commit :broadcast_row_update, if: :saved_change_to_status?

  # Dynamically define status check methods
  STATUSES.each do |status_name|
    define_method("#{status_name}?") do
      status == status_name
    end
  end

  private

  def broadcast_row_update
    # Broadcast the import status update to the import channel, with fresh instance after status update
    fresh = Import.find(id)

    broadcast_replace_to(
      "imports",
      target: "import_#{id}",
      partial: "imports/import",
      locals: { import: fresh }
    )
  end
end
