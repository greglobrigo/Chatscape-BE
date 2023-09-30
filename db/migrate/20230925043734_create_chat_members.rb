class CreateChatMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :chat_members do |t|
      t.integer :chat_id, foreign_key: true
      t.uuid :user_id, foreign_key: true
      t.integer :last_read_message_id

      t.timestamps
    end

    add_foreign_key :chat_members, :chats
    add_foreign_key :chat_members, :users
  end
end
