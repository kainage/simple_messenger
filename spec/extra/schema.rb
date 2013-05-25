ActiveRecord::Schema.define :version => 0 do
  create_table :messages do |t|
    t.references :sender, polymorphic: true, null: false
    t.references :receiver, polymorphic: true, null: false
    t.string :subject
    t.text :content, :null => false
    t.boolean :viewed, :null => false, :default => false

    t.timestamps
  end

  add_index :messages, [:sender_id, :sender_type]
  add_index :messages, [:receiver_id, :receiver_type]

  create_table :users do |t|
    t.string :username
    t.text :email
  end
end