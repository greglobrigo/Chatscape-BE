class Messages::MessagesController < ApplicationController
  def send_message
    request_body = JSON.parse(request.body.read)
    chat_id = request_body['chat_id']
    user_id = request_body['user_id']
    message_text = request_body['message_text']
    message = Message.create(chat_id:, user_id:, message_text:)
    if message.persisted?
      render json: { message: 'Message sent successfully', message: }, status: :ok
    else
      render json: { message: 'Message sending failed', errors: message.errors }, status: :unprocessable_entity
    end
  end

  def get_messages
    request_body = JSON.parse(request.body.read)
    user_id = request_body['user_id']
    chat_id = request_body['chat_id']
    messages = Message.where(user_id:, chat_id:)
    if messages.nil?
      render json: { message: 'Messages not found' }, status: :not_found
    else
      render json: { message: 'Messages found', messages: }, status: :ok
    end
  end
end
