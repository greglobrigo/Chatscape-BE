class ChatsController < ApplicationController
   def new
        request_body = JSON.parse(request.body.read)
        chat_name = request_body["chat_name"]
        chat_type = request_body["chat_type"]
        chat = Chat.create(chat_name: chat_name, chat_type: chat_type)
        if chat.persisted?
            render json: chat
        else
            render json: chat.errors
        end
   end
end
