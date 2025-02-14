class AddInsightsToCreators < ActiveRecord::Migration[5.0]
  def change
    add_column :creators, :insights, :jsonb, default: {}
  end
end
