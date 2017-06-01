class CreateAccountCampaign < ActiveRecord::Migration[5.0]
  def change
    create_table :account_campaigns do |t|
      t.integer :account_id
      t.integer :campaign_id

      t.timestamps
    end
  end
end
