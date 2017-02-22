class TriggerRefreshCreatorDetails < ActiveRecord::Migration[5.0]
  def change
    execute %{
      CREATE OR REPLACE FUNCTION
          func_refresh_creator_details()
          RETURNS TRIGGER LANGUAGE PLPGSQL
        AS $$
        BEGIN
          REFRESH MATERIALIZED VIEW CONCURRENTLY creator_details;
          RETURN NULL;
        EXCEPTION
          WHEN feature_not_supported THEN
            RETURN NULL;
        END $$;
      }

    %w(creators creators_shipping_addresses creators_billing_addresses addresses).each do |table|
      execute %{
        CREATE TRIGGER trigger_refresh_creator_details AFTER
              INSERT OR
              UPDATE OR
              DELETE
            ON #{table}
              FOR EACH STATEMENT
                EXECUTE PROCEDURE
                  func_refresh_creator_details()
        }
    end
  end
end
