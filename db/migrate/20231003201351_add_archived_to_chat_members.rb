class AddArchivedToChatMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :chat_members, :archived, :boolean
    add_column :chat_members, :default, :string
    add_column :chat_members, :false, :string
  end
end
