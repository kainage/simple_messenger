# Acts As Messenger

Add messaging functionality to active record models.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'acts_as_messenger'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install acts_as_messenger
```

Run the generator to create the migration file:

```
$ rails g features
```

Migrate the database:

```
$ rake db:migrate
```

## Usage

### Messenger Model

Add the appropriate line to the top of your activerecord model:

```ruby
class User
  acts_as_messenger
end
```

The class is not restricted to User, it can be any class you add ```acts_as_messenger``` to.

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


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
