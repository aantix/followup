class AddTokensToUsers < ActiveRecord::Migration
  def change
    add_column :users, :omniauth_token, :string
    add_column :users, :omniauth_refresh_token, :string
    add_column :users, :omniauth_expires_at, :datetime
    add_column :users, :omniauth_expires, :boolean
  end
end
