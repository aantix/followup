class RemoveBodyFromEmails < ActiveRecord::Migration
  def change
    remove_column :emails, :body
  end
end
