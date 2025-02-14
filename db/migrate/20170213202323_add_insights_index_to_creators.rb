class AddInsightsIndexToCreators < ActiveRecord::Migration[5.0]
  def change
    execute %{
      create index on creators using GIN (insights jsonb_ops)
    }
  end
end
