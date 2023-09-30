class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.integer :chat_id, foreign_key: true
      t.uuid :user_id, foreign_key: true
      t.string :message_text

      t.timestamps
    end
    add_foreign_key :messages, :chats
    add_foreign_key :messages, :users
  end
end
