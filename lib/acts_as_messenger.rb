require "acts_as_messenger/version"

require 'active_record' unless defined? Rails
require 'acts_as_messenger/message_additions'
require 'acts_as_messenger/messenger_additions'
require 'acts_as_messenger/models/message'
