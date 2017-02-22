class AddUsersRolesIndex < ActiveRecord::Migration[5.0]
  def change
    execute %{
      CREATE INDEX users_roles ON users USING GIN (roles)
    }
  end
end
