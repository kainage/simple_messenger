class User < ActiveRecord::Base
  acts_as_messenger
end

class Message < ActiveRecord::Base
  include ActsAsMessenger::MessageAdditions
end