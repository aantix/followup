class CreateEmailThreads < ActiveRecord::Migration
  def change
    create_table :email_threads do |t|
      t.integer :user_id
      t.string :thread_id
      t.datetime :last_email_at
      t.integer :emails_count, default: 0

      t.timestamps
    end
  end
end
