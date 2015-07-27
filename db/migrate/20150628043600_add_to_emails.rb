class AddToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :to_email, :string, after: :from_name
    add_column :emails, :to_name, :string, after: :to_email
  end
end
