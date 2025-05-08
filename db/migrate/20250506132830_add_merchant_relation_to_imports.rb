class AddMerchantRelationToImports < ActiveRecord::Migration[8.0]
  def change
    add_reference :imports, :merchant, null: false, foreign_key: true
  end

  add_index :imports, :merchant_id, unique: true
end
