class EmailThread < ActiveRecord::Base
  has_many :emails, dependent: :destroy

end
