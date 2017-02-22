class AddStatusEnumToCreator < ActiveRecord::Migration[5.0]
  def up
    execute %{ CREATE TYPE
        creator_status
      AS ENUM
        ('signed_up', 'verified', 'inactive' )
    }

    add_column :creators, :status, 'creator_status', default: 'signed_up', null: false
  end

  def down
    remove_column :creators, :status

    execute %{
        DROP TYPE creator_status
    }
    end
end
