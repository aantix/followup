class AddHtmlBodyToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :html_body, :text, after: :body
    add_column :emails, :plain_body, :text, after: :body
  end
end
