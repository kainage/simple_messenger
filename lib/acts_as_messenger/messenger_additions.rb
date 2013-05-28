module ActiveRecord
  module Acts
    module MessengerAdditions
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_messenger
          has_many :sent_messages,
            :as => :sender,
            :class_name => 'Message',
            :dependent => :destroy

          has_many :received_messages,
            :as => :receiver,
            :class_name => 'Message',
            :dependent => :destroy

          include ActiveRecord::Acts::MessengerAdditions::InstanceMethods
        end
      end

      module InstanceMethods
        def messages
          Message.all_for(self)
        end

        def new_messages
          received_messages.unviewed
        end

        def messages_with(other_messenger)
          Message.between([self, other_messenger])
        end

        # Build helper instead of typing User.sent_messages.build
        def build_message(*args)
          sent_messages.build(*args)
        end

        # New helper instead of typing User.sent_messages.new
        def new_message(*args)
          sent_messages.new(*args)
        end

        # Create helper instead of typing User.sent_messages.create
        def create_message(*args)
          sent_messages.create(*args)
        end

        # Create! helper instead of typing User.sent_messages.create!
        def create_message!(*args)
          sent_messages.create!(*args)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::MessengerAdditions)