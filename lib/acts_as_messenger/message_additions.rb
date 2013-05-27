module ActsAsMessenger
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

      # Check if the message has been read by the recipient for highlighting
      # in a conversation. Without the check for the user being the recipient,
      # the messages that she sent would return true.
      def read?(obj)
        obj == receiver && viewed?
      end

      def opposite_of(obj)
        case obj
        when sender
          receiver
        when receiver
          sender
        else
          raise ActsAsMessenger::NotInvolved
        end
      end
    end
  end
end