class Message < ApplicationRecord
    belongs_to :chat
    belongs_to :user
    validates :message_text, presence: true
    validates :sender, presence: true
    after_create_commit { broadcast_message }

    private

    def broadcast_message
        ActionCable.server.broadcast("MessagesChannel", {
            id:,
            chat_id:,
            user_id:,
            message_text:,
            created_at:,
            event_message:,
            sender:,
            avatar: User.where(id: self.user_id).first.avatar
        })
    end
end
