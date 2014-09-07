class EmailThread < ActiveRecord::Base
  acts_as_paranoid

  has_many :emails,-> {order "received_on asc"}, dependent: :destroy

end
