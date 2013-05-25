module ActiveRecord
  module Acts
    module MessengerAdditions
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_messenger
          has_many :sent_messages,
            :class_name => 'Message',
            :foreign_key => :sender_id

          has_many :received_messages,
            :class_name => 'Message',
            :foreign_key => :receiver_id

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

        def conversation_with(other_messenger)
          Message.conversation_between([self, other_messenger])
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::MessengerAdditions)