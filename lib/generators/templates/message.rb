class Message < ActiveRecord::Base
  include SimpleMessenger::MessageAdditions
end