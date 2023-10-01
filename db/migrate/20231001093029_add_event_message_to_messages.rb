class AddEventMessageToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :event_message, :boolean, default: false
  end
end
