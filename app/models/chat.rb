class Chat < ApplicationRecord
    validates :chat_name, presence: true
    validates :chat_type, presence: true, inclusion: { in: %w(direct public group)}
end
