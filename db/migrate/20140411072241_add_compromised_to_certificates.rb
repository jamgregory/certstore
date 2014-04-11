class AddCompromisedToCertificates < ActiveRecord::Migration
  def change
    add_column :certificates, :compromised, :boolean, default: false
  end
end
