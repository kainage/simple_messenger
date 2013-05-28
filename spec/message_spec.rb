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

  context "class methods" do
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

    describe "finding uniq members" do
      before :each do
        @user3 = User.create!
        @messages = [
          Message.create!(msg(@user1)),
          Message.create!(msg(@user2)),
          Message.create!(msg(@user3))
        ]
      end

      it "should return uniq memeber" do
        Message.uniq_member_ids_for(@messages).should =~
          [1234, @user1.id, @user2.id, @user3.id]
      end

      it "should remove a given fixnum" do
        Message.uniq_member_ids_for(@messages, remove: 1234).should =~
          [@user1.id, @user2.id, @user3.id]
      end

      it "should remove a given array of fixnum" do
        Message.uniq_member_ids_for(@messages, remove: [@user1.id, @user2.id]).should =~
          [1234, @user3.id]
      end

      it "should remove a given ar object" do
        Message.uniq_member_ids_for(@messages, remove: @user1).should =~
          [1234, @user2.id, @user3.id]
      end

      it "should remove a given array of ar objects" do
        Message.uniq_member_ids_for(@messages, remove: [@user1, @user2]).should =~
          [1234, @user3.id]
      end
    end
  end

  context "instance methods" do
    specify { @message.read?(@user1).should be_false }
    specify { @message.read?(@user2).should be_false }

    it "should act as viewed when applicable" do
      @message.viewed = true
      @message.read?(@user1).should be_false
      @message.read?(@user2).should be_true
    end

    it "should return the opposite model" do
      @message.member_who_is_not(@user1).should eq @user2
      @message.member_who_is_not(@user2).should eq @user1
    end

    it "should raise execption if passed model is neither sender or receiver" do
      expect { @message.member_who_is_not(User.create!) }.to raise_error ActsAsMessenger::NotInvolved
    end
  end
end