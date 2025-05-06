class AddPasswordDigestToMerchant < ActiveRecord::Migration[8.0]
  def change
    add_column :merchants, :password_digest, :string
  end
end
