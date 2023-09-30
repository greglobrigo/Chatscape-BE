class ChatMember < ApplicationRecord
    belongs_to :chat
    belongs_to :user
    validates :chat_id, presence: true
    validates :user_id, presence: true
end
