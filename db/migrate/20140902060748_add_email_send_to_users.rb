class AddEmailSendToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_send, :datetime, default: '2014-01-01 17:00:00'
  end
end
