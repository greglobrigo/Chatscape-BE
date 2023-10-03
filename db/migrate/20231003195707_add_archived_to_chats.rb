class AddArchivedToChats < ActiveRecord::Migration[7.0]
  def change
    add_column :chats, :archived, :boolean, default: false
  end
end
