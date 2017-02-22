class AddLowercaseIndexesToCreators < ActiveRecord::Migration[5.0]
  def up
    execute %{ CREATE INDEX
      creators_lower_last_name
    ON
      creators (lower(last_name) varchar_pattern_ops)
    }
    
    execute %{ CREATE INDEX
      creators_lower_first_name
    ON
      creators (lower(first_name) varchar_pattern_ops)
    }
    execute %{ CREATE INDEX
      creators_lower_email
    ON
      creators (lower(email))
    }
  end

  def down
    remove_index :creators, name: 'creators_lower_last_name' 
    remove_index :creators, name: 'creators_lower_first_name' 
    remove_index :creators, name: 'creators_lower_email'
  end
end
