class AddInsightsToCreators < ActiveRecord::Migration[5.0]
  def change
    add_column :creators, :insights, :json, default: {}
  end
end
