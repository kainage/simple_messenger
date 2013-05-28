class Message < ActiveRecord::Base
  include ActsAsMessenger::MessageAdditions
end