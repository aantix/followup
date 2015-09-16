class EmailThread < ActiveRecord::Base
  #acts_as_paranoid

  has_many :emails,-> {where(filtered: false).order("received_on asc")}, dependent: :destroy

end
