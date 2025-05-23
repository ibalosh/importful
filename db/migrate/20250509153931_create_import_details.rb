class CreateImportDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :import_details do |t|
      t.references :import, null: false, foreign_key: true
      t.integer :row_number
      t.json :error_messages, null: false, default: []
      t.json :payload, default: ""

      t.timestamps
    end
  end
end
