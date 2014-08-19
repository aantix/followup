class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :email_id
      t.text :question

      t.timestamps
    end
  end
end
