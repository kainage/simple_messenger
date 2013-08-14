require 'spec_helper'

describe SimpleMessenger::MessengerAdditions do
  # puts ActiveRecord::Base.connection.execute("PRAGMA table_info(messages);")
  # Helper method to make messages quickly
  def msg(uzer, recip: false, read: false, send_type: 'User', recip_type: 'User')
    if recip
      {
        sender_id: 1234, sender_type: send_type, receiver_id: uzer.id,
        receiver_type: recip_type, content: 'Hello', viewed: read
      }
    else
      {
        sender_id: uzer.id, sender_type: send_type, receiver_id: 1234,
        receiver_type: recip_type, content: 'Hello', viewed: read
      }
    end
  end

  before :each do
    @user1 = User.create!
    @user2 = User.create!
    @message = Message.create!(sender: @user1, receiver: @user2, content: 'Hello')
  end

  it "should return all sent messages" do
    @user1.sent_messages.count.should eql 1

    Message.create! msg(@user1)
    @user1.sent_messages.count.should eql 2

    Message.create! msg(@user1, recip: true)
    @user1.sent_messages.count.should eql 2
  end

  it "should return all received messages"do
    @user1.received_messages.count.should eql 0

    Message.create! msg(@user1)
    @user1.received_messages.count.should eql 0

    Message.create! msg(@user1, recip: true)
    @user1.received_messages.count.should eql 1
  end

  context "all messages" do
    it "should return all" do
      @user1.messages.count.should eql 1

      Message.create! msg(@user1)
      @user1.messages.count.should eql 2

      Message.create! msg(@user1, recip: true)
      @user1.messages.count.should eql 3
    end

    it "should return all of a sender type" do
      @user1.messages.count.should eql 1

      Message.create! msg(@user1, recip_type: 'Foo')
      @user1.messages.count.should eql 2
      @user1.messages(receiver_type: :user).count.should eql 1
      @user1.messages(receiver_type: :foo).count.should eql 1
    end


    it "should return all of a receiver type" do
      @user1.messages.count.should eql 1

      Message.create!(sender_id: 1234, sender_type: 'Foo', receiver: @user1, content: 'Hello')
      @user1.messages.count.should eql 2
      @user1.messages(sender_type: :user).count.should eql 1
      @user1.messages(sender_type: :foo).count.should eql 1
    end
  end

  it "should return all new messages" do
    @user1.new_messages.count.should eql 0

    Message.create! msg(@user1, recip: true)
    @user1.new_messages.count.should eql 1

    Message.create! msg(@user1, recip: true, read: true)
    @user1.new_messages.count.should eql 1
  end

  it "should give all the messages between 2 models" do
    @user1.messages_with(@user2).count.should eql 1

    Message.create!(sender: @user1, receiver: @user2, content: 'Hello')
    @user1.messages_with(@user2).count.should eql 2

    Message.create!(msg(@user1)) # Different user
    @user1.messages_with(@user2).count.should eql 2
  end

  it "should give all the messages received with another model" do
    @user1.received_messages_from(@user2).count.should eql 0

    Message.create!(sender: @user1, receiver: @user2, content: 'Hello')
    @user1.received_messages_from(@user2).count.should eql 0

    Message.create!(msg(@user1)) # Different user
    @user1.received_messages_from(@user2).count.should eql 0

    Message.create!(msg(@user1, recip: true)) # Different user
    @user1.received_messages_from(@user2).count.should eql 0
  end

  it "should give all the messages sent with another model" do
    @user1.sent_messages_to(@user2).count.should eql 1

    Message.create!(sender: @user1, receiver: @user2, content: 'Hello')
    @user1.sent_messages_to(@user2).count.should eql 2

    Message.create!(msg(@user1)) # Different user
    @user1.sent_messages_to(@user2).count.should eql 2

    Message.create!(msg(@user1, recip: true)) # Different user
    @user1.sent_messages_to(@user2).count.should eql 2
  end

  context "for @user2" do
    it "should give all the messages received with another model" do
      @user2.received_messages_from(@user1).count.should eql 1

      Message.create!(sender: @user1, receiver: @user2, content: 'Hello')
      @user2.received_messages_from(@user2).count.should eql 2

      Message.create!(msg(@user1)) # Different user
      @user2.received_messages_from(@user2).count.should eql 2

      Message.create!(msg(@user1, recip: true)) # Different user
      @user2.received_messages_from(@user2).count.should eql 2
    end

    it "should give all the messages sent with another model" do
      @user2.sent_messages_to(@user1).count.should eql 0

      Message.create!(sender: @user1, receiver: @user2, content: 'Hello')
      @user2.sent_messages_to(@user1).count.should eql 0

      Message.create!(msg(@user2)) # Different user
      @user2.sent_messages_to(@user1).count.should eql 0

      Message.create!(msg(@user2, recip: true)) # Different user
      @user2.sent_messages_to(@user1).count.should eql 0
    end
  end

  context "build helpers" do
    specify { expect(@user1.build_message).to be_kind_of(Message) }
    specify { expect(@user1.build_message.new_record?).to be_true }

    specify { expect(@user1.new_message).to be_kind_of(Message) }
    specify { expect(@user1.new_message.new_record?).to be_true }

    specify { expect(@user1.create_message(msg @user1)).to be_kind_of(Message) }
    specify { expect(@user1.create_message(msg @user1).new_record?).to be_false }

    specify { expect(@user1.create_message!(msg @user1)).to be_kind_of(Message) }
    specify { expect(@user1.create_message!(msg @user1).new_record?).to be_false }
  end
end