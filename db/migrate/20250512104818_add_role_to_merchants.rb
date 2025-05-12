class AddRoleToMerchants < ActiveRecord::Migration[8.0]
  def change
    add_column :merchants, :role, :string, null: false, default: 'regular'
    add_check_constraint :merchants, "role IN ('regular','admin')", name: "merchants_role_check"
  end
end
