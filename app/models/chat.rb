class Chat < ApplicationRecord
    has_many :messages, dependent: :destroy
    has_many :chat_users, dependent: :destroy
    has_many :users, through: :chat_users
    validates :chat_name, presence: true
    validates :chat_type, presence: true, inclusion: { in: %w(direct public group)}
end
