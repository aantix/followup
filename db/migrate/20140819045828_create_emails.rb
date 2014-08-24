class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.integer :email_thread_id
      t.string :message_id
      t.string :from_email
      t.string :from_name
      t.string :subject
      t.text :body
      t.string :content_type
      t.datetime :received_on
      t.integer :questions_count, default: 0

      t.timestamps
    end
  end
end
