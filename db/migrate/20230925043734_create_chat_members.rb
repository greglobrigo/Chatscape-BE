class CreateChatMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :chat_members do |t|
      t.integer :chat_id
      t.integer :user_id
      t.integer :last_read_message_id

      t.timestamps
    end
  end
end
