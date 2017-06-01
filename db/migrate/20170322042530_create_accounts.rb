class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.integer :creator_id
      t.string :type
      t.string :name

      t.timestamps
    end
  end
end
