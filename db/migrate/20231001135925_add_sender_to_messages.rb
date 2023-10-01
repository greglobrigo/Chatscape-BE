class AddSenderToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :sender, :string
  end
end
