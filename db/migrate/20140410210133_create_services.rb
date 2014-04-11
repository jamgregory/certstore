class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :address
      t.string :hostname
      t.integer :port
      t.references :certificate, index: true
      t.boolean :current

      t.timestamps
    end
  end
end
