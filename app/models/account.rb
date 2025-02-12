class Account < ApplicationRecord
  has_many :account_campaigns
  has_many :campaigns, through: :account_campaigns

  def self.list_campaigns
    joins(:account_campaigns).select('accounts.id, array_agg(campaign_id) AS campaign_ids').group('accounts.id')
  end
end
