class Chats::ChatsController < ApplicationController
  def create_public_or_group
    request_body = JSON.parse(request.body.read)
    chat_name = request_body['chat_name']
    chat_type = request_body['chat_type']
    user_id = request_body['user_id']
    participants = request_body['chat_members']


    userexists = User.where(id: user_id).exists?
    return render json: { status: 'failed', error: 'User not found' }, status: :not_found unless userexists

    if participants && participants.length > 0
        participants.each do |participant|
            if participant == user_id
                return render json: { status: 'failed', error: 'User cannot be a participant' }, status: :unprocessable_entity
            end
            memberexists = User.where(id: participant).exists?
            return render json: { status: 'failed', error: 'Member not found' }, status: :not_found unless memberexists
        end
    end

    chat = Chat.create(chat_name:, chat_type:)
    unless chat.persisted?
      return render json: { status: 'failed', error: 'Chat creation failed', errors: chat.errors }, status: :unprocessable_entity
    end

    chat_member = ChatMember.create(chat_id: chat.id, user_id:)
    unless chat_member.persisted?
      return render json: { status: 'failed', error: 'Chat creation failed', errors: chat_member.errors }, status: :unprocessable_entity
    end

    if participants && participants.length > 0
      participants.each do |participant|
        chat_member = ChatMember.create(chat_id: chat.id, user_id: participant)
        unless chat_member.persisted?
          return render json: { status: 'failed', error: 'Chat creation failed', errors: chat_member.errors }, status: :unprocessable_entity
        end
      end
    end
    render json: { status: 'success', message: 'Chat created successfully', chat: chat }, status: :ok
  end

  def create_or_retrieve
    request_body = JSON.parse(request.body.read)
    sender = request_body['sender']
    receiver = request_body['receiver']
    participants = [sender, receiver]

    if participants.nil? || participants.length != 2
      return render json: { status: 'failed', error: 'Direct chat must have exactly 2 participants' }, status: :unprocessable_entity
    end

    member1 = participants[0]
    member2 = participants[1]

    userexists = User.where(id: member1).exists? && User.where(id: member2).exists?
    return render json: { status: 'failed', error: 'Useror users not found' }, status: :not_found unless userexists

    chat = Chat.joins(:chat_members).where(chat_members: {user_id: [member1, member2]}).group(:id).having("count(*) = 2").first
    if chat.present?
      messages = Message.where(chat_id: chat.id).order(created_at: :asc).limit(100)
      return render json: { status: 'success', message: 'Chat retrieved successfully', chat_id: chat.id, messages: messages }, status: :ok
    end

    chat = Chat.create(chat_name: 'Direct Chat', chat_type: 'direct')
    unless chat.persisted?
      return render json: { status: 'failed', error: 'Chat creation failed', errors: chat.errors.to_sentence }, status: :unprocessable_entity
    end

    participants.each do |participant|
      chat_member = ChatMember.create(chat_id: chat.id, user_id: participant)
      unless chat_member.persisted?
        return render json: { status: 'failed', error: 'Chat creation failed', errors: chat_member.errors.to_sentence }, status: :unprocessable_entity
      end
    end
    render json: { status: "success", message: 'Chat created successfully', chat_id: chat.id, messages: [] }, status: :ok
  end

  def delete
    request_body = JSON.parse(request.body.read)
    chat_id = request_body['chat_id']
    chat = Chat.find_by(id: chat_id)
    if chat.nil?
      render json: { status: 'failed', error: 'Chat not found' }, status: :not_found
    else
      chat.destroy
      render json: { status: "success", message: 'Chat deleted successfully' }, status: :ok
    end
  end
end
