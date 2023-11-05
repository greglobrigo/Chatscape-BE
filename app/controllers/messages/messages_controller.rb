class Messages::MessagesController < ApplicationController
  before_action :validate_send_message, only: [:send_message]
  before_action :validate_get_message, only: [:get_messages]
  def send_message
    request_body = JSON.parse(request.body.read)
    chat_id = request_body['chat_id']
    user_id = request_body['sender']
    sender = User.find(user_id).name
    message_text = request_body['message_text']
    message = Message.create(chat_id:, user_id:, message_text:, sender:)
    chat = Chat.find(chat_id).update(updated_at: Time.now)
    if message.persisted? && chat
      render json: { status: 'success', message: 'Message sent successfully' }, status: :ok
    else
      render json: { status: 'failed', error: 'Message sending failed', errors: message.errors.full_messages.to_sentence },
             status: :ok
    end
  end

  def get_messages
    request_body = JSON.parse(request.body.read)
    user_id = request_body['user_id']
    chat_id = request_body['chat_id']
    messages = Chat.find(chat_id).messages.joins(:user).select('messages.*, users.avatar').order(created_at: :asc).last(30).map do |message|
      message.as_json(except: [:updated_at])
    end
    return render json: { status: 'success', message: 'Messages found', messages: messages }, status: :ok
  end

  def get_messages_gcm
    request_body = JSON.parse(request.body.read)
    user_id = request_body['user_id']
    chat_id = request_body['chat_id']
    messages = Chat.find(chat_id).messages.joins(:user).select('messages.*, users.avatar').order(created_at: :asc).last(30).map do |message|
      message.as_json(except: [:updated_at])
    end
  end

  def get_chats_and_messages
    request_body = JSON.parse(request.body.read)
    user_id = request_body['user_id']
    chat_id = request_body['chat_id']
    if chat_id && chat_id != 0 && user_id
      chats = Chat.joins(:chat_members)
      .where(chat_members: { user_id: user_id, archived: false }, chat_type: ['direct', 'group', 'public']).limit(10)
      .order(updated_at: :desc)
      .includes(:messages)
      .map { |chat| chat.as_json(include: { messages: { only: [:message_text, :sender, :user_id, :created_at] }}, except: [:created_at, :updated_at]) }
      .each { |chat| chat['messages'] = chat['messages'].last();
      chat['chat_type'] === 'public' || chat['chat_type'] === 'group' ?
      chat['members'] = ChatMember.where(chat_id: chat['id']).limit(3).map { |chat_member| User.where(id: chat_member.user_id).first.as_json(only: [:avatar]) } :
      chat['members'] = ChatMember.where(chat_id: chat['id']).limit(2).map { |chat_member| User.where(id: chat_member.user_id).first.as_json(only: [:id, :email, :handle, :name, :avatar]) };
      }
        render json: { status: 'success', message: 'Chats found', chats: chats, messages: get_messages_gcm }, status: :ok
    elsif chat_id == 0 && user_id
      chats = Chat.joins(:chat_members)
      .where(chat_members: { user_id: user_id, archived: false }, chat_type: ['direct', 'group', 'public']).limit(20)
      .order(updated_at: :desc)
      .includes(:messages)
      .map { |chat| chat.as_json(include: { messages: { only: [:message_text, :sender, :user_id, :created_at] }}, except: [:created_at, :updated_at]) }
      .each { |chat| chat['messages'] = chat['messages'].last();
      chat['chat_type'] === 'public' || chat['chat_type'] === 'group' ?
      chat['members'] = ChatMember.where(chat_id: chat['id']).limit(3).map { |chat_member| User.where(id: chat_member.user_id).first.as_json(only: [:avatar]) } :
      chat['members'] = ChatMember.where(chat_id: chat['id']).limit(2).map { |chat_member| User.where(id: chat_member.user_id).first.as_json(only: [:id, :email, :handle, :name, :avatar]) };
      }
      render json: { status: 'success', message: 'Chats found', chats: chats, messages: [] }, status: :ok
    else
      render json: { status: 'failed', error: 'Invalid request' }, status: :ok
    end
  end

  private

  def send_message_params
    params.require(:message).permit(:chat_id, :sender, :message_text)
  end

  def validate_send_message
    if send_message_params[:chat_id].nil? || send_message_params[:sender].nil? || send_message_params[:message_text].nil?
      return render json: { status: 'failed', error: 'Invalid parameters' }, status: :ok
    end

    chat = Chat.joins(:users).where(id: send_message_params[:chat_id],
                                    users: { id: send_message_params[:sender] }).first
    return if chat

    render json: { status: 'failed', error: 'User not found, chat not found, or user is not a member of the chat' },
           status: :ok
  end

  def get_message_params
    params.require(:message).permit(:chat_id, :user_id)
  end

  def validate_get_message
    if get_message_params[:chat_id].nil? || get_message_params[:user_id].nil?
      return render json: { status: 'failed', error: 'Invalid parameters' }, status: :ok
    end

    chat = Chat.joins(:users).where(id: get_message_params[:chat_id], users: { id: get_message_params[:user_id] }).first
    return if chat

    render json: { status: 'failed', error: 'User not found, chat not found, or user is not a member of the chat' },
           status: :ok
  end
end
