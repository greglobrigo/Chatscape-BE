class User < ApplicationRecord
    has_many :messages, dependent: :destroy
    has_many :chats, through: :messages
    has_many :chat_members, dependent: :destroy
    has_many :chats, through: :chat_members
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true, length: { minimum: 16 }
    validates :status, presence: true, inclusion: { in: %w[active unauthenticated] }
end
