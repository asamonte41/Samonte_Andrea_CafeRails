class AddDefaultRoleToUsers < ActiveRecord::Migration[8.1]
  def up
    # Set role to 0 (customer) for existing users with NULL
    User.where(role: nil).update_all(role: 0)
  end

  def down
    # Do nothing
  end
end
