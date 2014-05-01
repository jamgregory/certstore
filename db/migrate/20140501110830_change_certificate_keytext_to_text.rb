class ChangeCertificateKeytextToText < ActiveRecord::Migration
  def change
    change_column :certificates, :keytext, :text
  end
end
