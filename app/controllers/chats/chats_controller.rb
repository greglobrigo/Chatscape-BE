class Chats::ChatsController < ApplicationController
   def new
        request_body = JSON.parse(request.body.read)
        chat_name = request_body["chat_name"]
        chat_type = request_body["chat_type"]
        chat = Chat.create(chat_name: chat_name, chat_type: chat_type)
        if chat.persisted?
            render json: {message: "Chat created successfully", chat: chat}, status: :ok
        else
            render json: {message: "Chat creation failed", errors: chat.errors}, status: :unprocessable_entity
        end
   end

   def delete
        request_body = JSON.parse(request.body.read)
        chat_id = request_body["chat_id"]
        chat = Chat.find_by(id: chat_id)
        if chat.nil?
            render json: {message: "Chat not found"}, status: :not_found
        else
            chat.destroy
            render json: {message: "Chat deleted successfully"}, status: :ok
        end
   end
end
