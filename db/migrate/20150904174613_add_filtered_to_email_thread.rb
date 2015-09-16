class AddFilteredToEmailThread < ActiveRecord::Migration
  def change
    add_column :email_threads, :filtered, :boolean, default: true
  end
end
