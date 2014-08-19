class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.integer :user_id
      t.string :thread_id
      t.string :message_id
      t.string :from
      t.string :subject
      t.text :body
      t.datetime :received_on

      t.timestamps
    end
  end
end
