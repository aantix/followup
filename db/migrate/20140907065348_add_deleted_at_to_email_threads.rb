class AddDeletedAtToEmailThreads < ActiveRecord::Migration
  def change
    add_column :email_threads, :deleted_at, :datetime
    add_index :email_threads, :deleted_at
  end
end
