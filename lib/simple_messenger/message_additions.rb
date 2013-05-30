module SimpleMessenger
  class NotInvolved < StandardError; end

  module MessageAdditions
    def self.included(feature_model)
      feature_model.belongs_to :sender, polymorphic: true
      feature_model.belongs_to :receiver, polymorphic: true

      feature_model.scope :unviewed, -> { feature_model.where(viewed: false) }

      # Using ARel find all the messages where the model is sender or receiver.
      feature_model.scope :all_for, ->(model) {
        feature_model.where(
             ((feature_model.arel_table[:sender_id].eq model.id).
          and(feature_model.arel_table[:sender_type].eq model.class.to_s)).
           or((feature_model.arel_table[:receiver_id].eq model.id).
          and(feature_model.arel_table[:receiver_type].eq model.class.to_s))
         )
       }

      # Find a conversations between 2 models by joining all_for on both.
      feature_model.scope :between, ->(models) {
        feature_model.all_for(models.first).all_for(models.last)
      }

      feature_model.validates_presence_of :sender_id, :sender_type,
                                          :receiver_id, :receiver_type

      # When given an array of messages, this will return a list of all the ids of the
      # models that have interacted together. Useful for creating a list of objects
      # which a given object has communicated with.
      #
      # remove is optional and takes a fixnum, object or array of either and will remove
      # it's id from the list. Useful for sending a current_user in to get a unique
      # list of other users which they have communicated with.
      def feature_model.uniq_member_ids_for(msgs, remove:nil)
        ids = msgs.map { |m| [m.receiver_id, m.sender_id] }.flatten.uniq
        ids -= case
        when remove.respond_to?(:first)
          # If remove is an array, check for ActiveRecord object, if not return the element
          remove.first.respond_to?(:id) ? remove.map(&:id) : remove
        else
          # Check for ActiveRecord object, otherwise return the passed object
          [remove.respond_to?(:id) ? remove.id : remove].flatten
        end if remove
        ids
      end

      # Check if the message has been read by the recipient for highlighting
      # in a conversation. Without the check for the user being the recipient,
      # the messages that she sent would return true.
      def read?(obj)
        obj == receiver && viewed?
      end

      # This will return the other member in the communication then the one
      # provided. Note: still struggling with a good name for this method.
      def member_who_is_not(obj)
        case obj
        when sender
          receiver
        when receiver
          sender
        else
          raise SimpleMessenger::NotInvolved
        end
      end
    end
  end
end