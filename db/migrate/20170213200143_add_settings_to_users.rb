class AddSettingsToUsers < ActiveRecord::Migration[5.0]
  def up
    enable_extension :hstore
    add_column :users, :settings, :hstore, default: {}
  end

  def down
    remove_column :users, :settings
    disable_extension :hstore
  end
end
