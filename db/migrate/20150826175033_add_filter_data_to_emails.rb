class AddFilterDataToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :filtered, :boolean, default: true, after: :email_thread_id
    add_column :emails, :filtered_message, :string, after: :filtered
  end
end
