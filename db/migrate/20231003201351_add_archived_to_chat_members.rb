class AddArchivedToChatMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :chat_members, :archived, :boolean, default: false
  end
end
