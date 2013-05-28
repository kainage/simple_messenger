require 'rails/generators/migration'

class MessagesGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path("../templates", __FILE__)

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def create_acts_as_messenger_files
    copy_file "message.rb", "app/models/message.rb"
    migration_template "create_messages.rb", "db/migrate/create_messages.rb"
  end
end