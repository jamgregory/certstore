class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.string :keytext

      t.timestamps
    end
  end
end
