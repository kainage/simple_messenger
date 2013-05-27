require 'spec_helper'

describe Message do
  # puts ActiveRecord::Base.connection.execute("PRAGMA table_info(messages);")
  # Helper method to make messages quickly
  def msg(uzer, recip = false)
    if recip
      {
        sender_id: 1234, sender_type: 'User', receiver_id: uzer.id,
        receiver_type: 'User', content: 'Hello'
      }
    else
      {
        sender_id: uzer.id, sender_type: 'User', receiver_id: 1234,
        receiver_type: 'User', content: 'Hello'
      }
    end
  end

  before :each do
    @user1 = User.create!
    @user2 = User.create!
    @message = Message.create!(sender: @user1, receiver: @user2, content: 'Hello')
  end

  specify { @message.should be_valid }
  specify { @message.should belong_to(:sender) }
  specify { @message.should belong_to(:receiver) }

  specify { @message.should validate_presence_of(:sender_id) }
  specify { @message.should validate_presence_of(:sender_type) }
  specify { @message.should validate_presence_of(:receiver_id) }
  specify { @message.should validate_presence_of(:receiver_type) }

  it "should give you all messaged wheather you are the seder or recipient" do
    Message.all_for(@user1).count.should eql 1

    Message.create! msg(@user1)
    Message.all_for(@user1).count.should eql 2

    Message.create! msg(@user1, true)
    Message.all_for(@user1).count.should eql 3
  end

  it "should give all the messages between you and another user" do
    Message.between([@user1, @user2]).count.should eql 1

    Message.create!(sender: @user1, receiver: @user2, content: 'Hello')
    Message.between([@user1, @user2]).count.should eql 2

    Message.create!(msg(@user1))
    Message.between([@user1, @user2]).count.should eql 2
  end

  specify { @message.read?(@user1).should be_false }
  specify { @message.read?(@user2).should be_false }

  it "should act as viewed when applicable" do
    @message.viewed = true
    @message.read?(@user1).should be_false
    @message.read?(@user2).should be_true
  end

  it "should return the opposite model" do
    @message.opposite_of(@user1).should eq @user2
    @message.opposite_of(@user2).should eq @user1
  end

  it "should raise execption if passed model is neither sender or receiver" do
    expect { @message.opposite_of(User.create!) }.to raise_error ActsAsMessenger::NotInvolved
  end
end