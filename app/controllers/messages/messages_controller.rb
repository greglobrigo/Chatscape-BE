class Messages::MessagesController < ApplicationController
  before_action :validate, only: [:send_message]
  def send_message
    request_body = JSON.parse(request.body.read)
    chat_id = request_body['chat_id']
    user_id = request_body['user_id']
    message_text = request_body['message_text']
    message = Message.create(chat_id:, user_id:, message_text:)
    if message.persisted?
      render json: { status: 'success', message: 'Message sent successfully' }, status: :ok
    else
      render json: { status: 'failed', message: 'Message sending failed', errors: message.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def get_messages
    request_body = JSON.parse(request.body.read)
    user_id = request_body['user_id']
    chat_id = request_body['chat_id']
    messages = Message.where(user_id:, chat_id:)
    if messages.nil?
      render json: { status: 'failed', message: 'Messages not found' }, status: :not_found
    else
      render json: { status: 'success', message: 'Messages found', messages: }, status: :ok
    end
  end

  private

  def message_params
    params.require(:message).permit(:chat_id, :user_id, :message_text)
  end

  def validate
    if message_params[:chat_id].nil? || message_params[:user_id].nil? || message_params[:message_text].nil?
      render json: { status: 'failed', message: 'Invalid parameters' }, status: :unprocessable_entity
    end
    chat = Chat.joins(:users).where(id: message_params[:chat_id], users: { id: message_params[:user_id] }).first
    return render json: { status: 'failed', message: 'User not found, chat not found, or user is not a member of the chat' }, status: :unprocessable_entity unless chat

    # chatexists = Chat.where(id: message_params[:chat_id]).exists?
    # return render json: { status: 'failed', message: 'Chat not found' }, status: :not_found unless chatexists
    # userexists = User.where(id: message_params[:user_id]).exists?
    # return render json: { status: 'failed', message: 'User not found' }, status: :not_found unless userexists

    # chat_member = ChatMember.where(chat_id: message_params[:chat_id], user_id: message_params[:user_id]).first
    # return render json: { status: 'failed', message: 'User is not a member of the chat' }, status: :unprocessable_entity unless chat_member
  end
end
