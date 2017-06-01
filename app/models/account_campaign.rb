class AccountCampaign < ApplicationRecord
  belongs_to :account
  belongs_to :campaign
end
