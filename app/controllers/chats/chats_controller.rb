class Chats::ChatsController < ApplicationController
  def create_public_or_group
    request_body = JSON.parse(request.body.read)
    chat_name = request_body['chat_name']
    chat_type = request_body['chat_type']
    user_id = request_body['user_id']
    participants = request_body['chat_members']


    user = User.where(id: user_id)
    return render json: { status: 'failed', error: 'User not found' }, status: :ok unless user.exists?

    if participants && participants.length > 0
        participants.each do |participant|
            if participant == user_id
                return render json: { status: 'failed', error: 'User cannot be a participant' }, status: :unprocessable_entity
            end
            memberexists = User.where(id: participant).exists?
            return render json: { status: 'failed', error: 'Member not found' }, status: :ok unless memberexists
        end
    end

    chat = Chat.create(chat_name:, chat_type:)
    unless chat.persisted?
      return render json: { status: 'failed', error: 'Chat creation failed', error: chat.errors }, status: :ok
    end

    chat_member = ChatMember.create(chat_id: chat.id, user_id:)
    unless chat_member.persisted?
      return render json: { status: 'failed', error: 'Chat creation failed', error: chat_member.errors }, status: :ok
    end

    if participants && participants.length > 0
      participants.each do |participant|
        chat_member = ChatMember.create(chat_id: chat.id, user_id: participant)
        unless chat_member.persisted?
          return render json: { status: 'failed', error: 'Chat creation failed', error: chat_member.errors }, status: :ok
        end
      end
    end

    message = Message.create(chat_id: chat.id, user_id: user_id, message_text: "#{user.first.name} created group chat #{chat_name}", sender: 'System', event_message: true)
    unless message.persisted?
      return render json: { status: 'failed', error: 'Chat creation failed', error: message.errors }, status: :ok
    end

    render json: { status: 'success', message: 'Chat created successfully', chat: chat }, status: :ok
  end

  def create_or_retrieve
    request_body = JSON.parse(request.body.read)
    sender = request_body['sender']
    receiver = request_body['receiver']
    participants = [sender, receiver]

    if participants.nil? || participants.length != 2
      return render json: { status: 'failed', error: 'Direct chat must have exactly 2 participants' }, status: :ok
    end

    member1 = participants[0]
    member2 = participants[1]

    userexists = User.where(id: member1).exists? && User.where(id: member2).exists?
    return render json: { status: 'failed', error: 'User or users not found' }, status: :not_found unless userexists

    chat = Chat.joins(:chat_members).where(chat_type: 'direct', chat_members: {user_id: [member1, member2]}).group(:id).having("count(*) = 2").first
    if chat.present?
      messages = Chat.find(chat.id).messages.joins(:user).select('messages.*, users.avatar').order(created_at: :asc).last(30).map { |message| message.as_json(except: [:updated_at]) }
      return render json: { status: 'success', message: 'Chat retrieved successfully', chat_id: chat.id, messages: messages }, status: :ok
    end

    chat = Chat.create(chat_name: 'Direct Chat', chat_type: 'direct')
    unless chat.persisted?
      return render json: { status: 'failed', error: 'Chat creation failed', errors: chat.errors.to_sentence }, status: :ok
    end

    participants.each do |participant|
      chat_member = ChatMember.create(chat_id: chat.id, user_id: participant)
      unless chat_member.persisted?
        return render json: { status: 'failed', error: 'Chat creation failed', errors: chat_member.errors.to_sentence }, status: :ok
      end
    end
    render json: { status: "success", message: 'Chat created successfully', chat_id: chat.id, messages: [] }, status: :ok
  end


  def search_public
    request_body = JSON.parse(request.body.read)
    search = request_body['searchTerm']
    user_id = request_body['user_id']
    chats = Chat.where("chat_name LIKE ? AND chat_type = 'public'", "%#{search}%").limit(5).map { |chat| chat.as_json(only: [:id, :chat_name, :chat_type]) }
    if chats
    chats.each do |chat|
      chat['members'] = User.joins(:chat_members).where(chat_members: { chat_id: chat['id'] }).limit(3).map { |user| user.as_json(only: [:avatar]) }
      chat['isMember'] = ChatMember.where(chat_id: chat['id'], user_id: user_id).exists?
    end
  else
    chats = []
  end
    render json: { status: 'success', message: 'Chats retrieved successfully', chats: chats }, status: :ok
  end

  def join_public
    request_body = JSON.parse(request.body.read)
    user_id = request_body['user_id']
    chat_id = request_body['chat_id']
    user = User.where(id: user_id)
    chat = Chat.where(id: chat_id, chat_type: 'public')
    return render json: { status: 'failed', error: 'Chat not found' }, status: :ok unless chat.exists?

    chat_member = ChatMember.create(chat_id: chat_id, user_id: user_id)
    unless chat_member.persisted?
      return render json: { status: 'failed', error: 'Chat creation failed', error: chat_member.errors }, status: :ok
    end

    message = Message.create(chat_id: chat_id, user_id: user_id, message_text: "#{user.first.name} joined #{chat.first.chat_name}", sender: 'System', event_message: true)
    return render json: { status: 'failed', error: 'Chat creation failed', error: message.errors }, status: :ok unless message.persisted?

    render json: { status: 'success', message: 'Chat joined successfully' }, status: :ok
  end
end
