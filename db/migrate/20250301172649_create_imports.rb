class CreateImports < ActiveRecord::Migration[8.0]
  def change
    create_table :imports do |t|
      t.string :status
      t.string :filename
      t.integer :total_records, default: 0, null: false
      t.integer :processed_records, default: 0, null: false
      t.integer :not_processed_records, default: 0, null: false

      t.timestamps
    end
  end
end
