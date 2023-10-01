class Chats::ChatsController < ApplicationController
  def create_public_or_group
    request_body = JSON.parse(request.body.read)
    chat_name = request_body['chat_name']
    chat_type = request_body['chat_type']
    user_id = request_body['user_id']
    participants = request_body['chat_members']


    userexists = User.where(id: user_id).exists?
    return render json: { status: 'failed', message: 'User not found' }, status: :not_found unless userexists

    if participants && participants.length > 0
        participants.each do |participant|
            if participant == user_id
                return render json: { status: 'failed', message: 'User cannot be a participant' }, status: :unprocessable_entity
            end
            memberexists = User.where(id: participant).exists?
            return render json: { status: 'failed', message: 'Member not found' }, status: :not_found unless memberexists
        end
    end

    chat = Chat.create(chat_name:, chat_type:)
    unless chat.persisted?
      return render json: { status: 'failed', message: 'Chat creation failed', errors: chat.errors }, status: :unprocessable_entity
    end

    chat_member = ChatMember.create(chat_id: chat.id, user_id:)
    unless chat_member.persisted?
      return render json: { status: 'failed', message: 'Chat creation failed', errors: chat_member.errors }, status: :unprocessable_entity
    end

    if participants && participants.length > 0
      participants.each do |participant|
        chat_member = ChatMember.create(chat_id: chat.id, user_id: participant)
        unless chat_member.persisted?
          return render json: { status: 'failed', message: 'Chat creation failed', errors: chat_member.errors }, status: :unprocessable_entity
        end
      end
    end
    render json: { status: 'success', message: 'Chat created successfully', chat: chat }, status: :ok
  end

  def create_direct
    request_body = JSON.parse(request.body.read)
    participants = request_body['chat_members']

    if participants.nil? || participants.length != 2
      return render json: { status: "failed", message: 'Direct chat must have exactly 2 participants' }, status: :unprocessable_entity
    end

    member1 = participants[0]
    member2 = participants[1]

    userexists = User.where(id: member1).exists? && User.where(id: member2).exists?
    return render json: { status: "failed", message: 'Useror users not found' }, status: :not_found unless userexists

    chat = Chat.where(chat_type: 'direct').where('chat_members.user_id = ? OR chat_members.user_id = ?', member1, member2).group('chats.id').having('COUNT(*) = 2').joins(:chat_members).first
    return render json: { status: "failed", message: 'Direct chat already exists' }, status: :unprocessable_entity if chat

    chat = Chat.create(chat_name: 'Direct Chat', chat_type: 'direct')
    unless chat.persisted?
      return render json: { status: "failed", message: 'Chat creation failed', errors: chat.errors.to_sentence }, status: :unprocessable_entity
    end

    participants.each do |participant|
      chat_member = ChatMember.create(chat_id: chat.id, user_id: participant)
      unless chat_member.persisted?
        return render json: { status: "failed", message: 'Chat creation failed', errors: chat_member.errors.to_sentence }, status: :unprocessable_entity
      end
    end
    render json: { status: "success", message: 'Chat created successfully', chat: }, status: :ok
  end

  def delete
    request_body = JSON.parse(request.body.read)
    chat_id = request_body['chat_id']
    chat = Chat.find_by(id: chat_id)
    if chat.nil?
      render json: { status: "failed", message: 'Chat not found' }, status: :not_found
    else
      chat.destroy
      render json: { status: "success", message: 'Chat deleted successfully' }, status: :ok
    end
  end
end
