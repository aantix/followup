class CreateEmailProfileImages < ActiveRecord::Migration
  def change
    create_table :email_profile_images do |t|
      t.string :email
      t.string :url

      t.timestamps
    end
  end
end
