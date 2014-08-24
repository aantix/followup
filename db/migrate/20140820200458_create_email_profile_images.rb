class CreateEmailProfileImages < ActiveRecord::Migration
  def change
    create_table :email_profile_images do |t|
      t.string :email
      t.string :url
      t.string :image
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
