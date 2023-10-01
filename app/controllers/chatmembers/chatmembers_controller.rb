class Chatmembers::ChatmembersController < ApplicationController
  def add
    request_body = JSON.parse(request.body.read)
    chat_id = request_body['chat_id']
    chat = Chat.find_by(id: chat_id)
    if chat.nil?
      return render json: { message: 'Chat not found' }, status: :not_found
    elsif chat.chat_type == 'direct'
        return render json: { status: "failed", message: 'Cannot add members to direct chat' }, status: :unprocessable_entity
    end

    participants = request_body['chat_members']
    return render json: { status: "failed", message: 'No members to add' }, status: :unprocessable_entity if participants.nil? || participants.length == 0

    participants.each do |participant|
        memberexists = User.where(id: participant).exists?
        return render json: { status: 'failed', message: 'Member not found' }, status: :not_found unless memberexists
    end

    participants.each do |participant|
      chat_member = ChatMember.create(chat_id:, user_id: participant)
      unless chat_member.persisted?
        return render json: { status: "failed", message: 'Chat creation failed', errors: chat_member.errors }, status: :unprocessable_entity
      end
    end
    render json: { status: "success", message: 'Chat created successfully', chat: }, status: :ok
  end
end
