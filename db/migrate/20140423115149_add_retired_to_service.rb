class AddRetiredToService < ActiveRecord::Migration
  def change
    add_column :services, :retired, :boolean, default: false
  end
end
