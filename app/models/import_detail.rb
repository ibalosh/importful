class ImportDetail < ApplicationRecord
  belongs_to :import
  broadcasts_to ->(details) { [ details.import, :import_details ] }
end
