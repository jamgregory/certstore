class CreateScans < ActiveRecord::Migration
  def change
    create_table :scans do |t|
      t.references :service, index: true
      t.references :certificate, index: true
      t.string :state
      t.string :message

      t.timestamps
    end
  end
end
