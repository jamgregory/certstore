class AddIndexToCertificate < ActiveRecord::Migration
  def change
    add_index :certificates, :keytext, unique: true
  end
end
