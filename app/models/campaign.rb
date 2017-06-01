class Campaign < ApplicationRecord
  has_many :account_campaigns
  has_many :accounts, through: :account_campaigns
end