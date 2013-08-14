module SimpleMessenger
  module MessengerAdditions
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def simple_messenger
        has_many :sent_messages,
          :as => :sender,
          :class_name => 'Message',
          :dependent => :destroy

        has_many :received_messages,
          :as => :receiver,
          :class_name => 'Message',
          :dependent => :destroy

        include SimpleMessenger::MessengerAdditions::InstanceMethods
      end
    end

    module InstanceMethods
      def messages(sender_type: nil, receiver_type: nil)
        msgs = Message.all_for(self)
        msgs = msgs.where(sender_type: sender_type.to_s.camelize) if sender_type
        msgs = msgs.where(receiver_type: receiver_type.to_s.camelize) if receiver_type
        msgs
      end

      def new_messages
        received_messages.unviewed
      end

      def messages_with(other_messenger)
        Message.between([self, other_messenger])
      end

      def received_messages_from(messenger)
        self.messages_with(messenger).where(receiver: self)
      end

      def sent_messages_to(messenger)
        self.messages_with(messenger).where(sender: self)
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

ActiveRecord::Base.send(:include, SimpleMessenger::MessengerAdditions)