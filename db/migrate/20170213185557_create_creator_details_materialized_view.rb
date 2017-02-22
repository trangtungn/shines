class CreateCreatorDetailsMaterializedView < ActiveRecord::Migration[5.0]
  def up
    execute %{
      CREATE MATERIALIZED VIEW creator_details AS
        SELECT
          creators.id,
          creators.first_name,
          creators.last_name,
          creators.email,
          creators.username,
          creators.created_at,
          billing_address.id AS billing_address_id,
          billing_address.street AS billing_address_street,
          billing_address.city AS billing_address_city,
          billing_state.code AS billing_address_code,
          billing_address.zipcode  AS billing_zipcode,
          shipping_address.id      AS shipping_address_id,
          shipping_address.street  AS shipping_street,
          shipping_address.city    AS shipping_city,
          shipping_state.code      AS shipping_state,
          shipping_address.zipcode AS shipping_zipcode
        FROM creators LEFT JOIN creators_billing_addresses ON creators.id = creators_billing_addresses.creator_id
                      LEFT JOIN addresses billing_address ON billing_address.id = creators_billing_addresses.address_id
                      LEFT JOIN states billing_state ON billing_address.state_id = billing_state.id
                      LEFT JOIN creators_shipping_addresses ON creators.id = creators_shipping_addresses.creator_id
                        AND creators_shipping_addresses.primary = true
                      LEFT JOIN addresses shipping_address ON shipping_address.id = creators_shipping_addresses.address_id
                      LEFT JOIN states shipping_state ON shipping_address.state_id = shipping_state.id
    }
    execute %{
      CREATE UNIQUE INDEX creator_details_creator_id ON creator_details(id)
    }
  end

  def down
    execute "DROP MATERIALIZED VIEW creator_details"
  end
end
