class EmailThread < ActiveRecord::Base
  has_many :emails,-> {order "received_on asc"}, dependent: :destroy

end
