# Simple Messenger

Add simple messaging functionality to active record models.

**Requires ruby >= 2.0.0**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_messenger'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install simple_messenger
```

Run the generator to create the migration file and message model:

```
$ rails g messages
```

Migrate the database:

```
$ rake db:migrate
```

## Usage

### Message Model

This will be generated and placed in your app/models folder:

```ruby
class Message
  include SimpleMessenger::MessageAdditions
end
```

You can add any custom functionality to the Message model here.

### Messenger Model

Add the appropriate line to the top of your activerecord model:

```ruby
class User
  simple_messenger
end
```

The class is not restricted to User, it can be any class you add ```simple_messenger``` to.

### Creating Messages

Send messages by passing in a sender, receiver and some content:

```ruby
bob = User.create
alice = User.create
bob.create_message!(receiver: alice, content: 'Hello')
# => <Message id: 1 sender_id: 1 sender_type 'User' ... content: "Hello" viewed: false>

bob.messages.count
# => 1

bob.sent_messages.count
# => 1

bob.received_messages.count
# => 0

bob.new_messages.count
# => 0

bob.messages_with(alice)
# => <Message id: 1 ... >

alice.messages.count
# => 1

alice.sent_messages.count
# => 0

alice.received_messages.count
# => 1

alice.new_messages.count
# => 1

alice.messages_with(bob)
# => <Message id: 1 ... >
```

### Messenger Helpers

The following constructors are available:

```ruby
bob.build_message
bob.new_message
bob.create_message
bob.create_message!
```

Due to the nature of the design you would have to type:

```ruby
bob.sent_messages.build ...
```

As typing the ```bob.messages``` returns a specialized relation and is not
created through a ```has_many``` relationship:

### Message Helpers

**Class Methods**

To get all the member ids in a collection of messages use the following:

```ruby
Message.uniq_member_ids_for(messages)
```

You can optionally omit one or more member from the collection:

```ruby
Message.uniq_member_ids_for(messages, remove: current_user)
```
This could be useful for rendering a list of users which the current_user has
messaged.

```remove``` can be an id, array of ids, ActiveRecord object, collection of
ActiveRecord objects, or anything that ```respond_to?(:id)```

**Instance Methods**

Check to see if the message has been read:

```ruby
msg = Message.create(sender: bob, receiver: alice, content: 'Hello')
# => <Message ... viewed: false>
msg.read?(bob) # true as bob is the sender
# => true
msg.read?(alice)
# => false
```

Find the opposite member in the message:

```ruby
msg = Message.create(sender: bob, receiver: alice, content: 'Hello')
# => <Message ... >
msg.member_who_is_not(bob)
# => <User ... username: 'alice'>
msg.member_who_is_not(alice)
# => <User ... username: 'bob'>
msg.member_who_is_not(jimmy)
# => SimpleMessenger::NotInvolved error
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
