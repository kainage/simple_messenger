class User < ActiveRecord::Base
  simple_messenger
end

class Message < ActiveRecord::Base
  include SimpleMessenger::MessageAdditions
end