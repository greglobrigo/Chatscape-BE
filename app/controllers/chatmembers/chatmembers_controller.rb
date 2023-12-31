class Chatmembers::ChatmembersController < ApplicationController
  before_action :validate_add_chat_member, only: [:add]
  before_action :validate_leave_chat_member, only: [:leave]
  def add
    request_body = JSON.parse(request.body.read)
    user_id = request_body['user_id']
    chat_id = request_body['chat_id']
    participants = request_body['chat_members']
    user = User.find_by(id: user_id)
    user_name = user.name
    chat = Chat.find_by(id: chat_id)

    return render json: { status: 'failed', error: 'Invalid request' }, status: :ok if chat_id.nil? || user_id.nil?
    return render json: { status: 'failed', error: 'No members to add' }, status: :ok if participants.nil? || participants.length == 0
    return render json: { status: 'failed', error: 'User not found' }, status: :ok if user.nil?
    return render json: { status: 'failed', error: 'Chat not found' }, status: :ok if chat.nil?

    added_members = []
    participants.each do |participant|
        member = User.find_by(id: participant)
        memberexists = !member.nil?
        return render json: { status: 'failed', error: 'Member not found' }, status: :ok unless memberexists
        if member.name
           added_members.push(member.name)
        elsif member.handle
           added_members.push(member.handle)
        else
            added_members.push(member.email)
        end
    end

      message_text = "#{added_members.length === 1 ? added_members[0] : added_members.length === 2 ? added_members.join(' and ') : added_members[0..-2].join(', ') + ' and ' + added_members[-1]} has been added to the chat by #{user_name}."
      message = Message.create(chat_id: chat_id, user_id: user_id, message_text: message_text, event_message: true, sender: 'System')
      return render json: { status: 'failed', error: 'System message creation failed', error: message.errors.full_messages.to_sentence }, status: :ok unless message.persisted?

    participants.each do |participant|
      chat_member = ChatMember.create(chat_id:, user_id: participant)
      unless chat_member.persisted?
        return render json: { status: 'failed', error: 'Chat creation failed', error: chat_member.errors }, status: :ok
      end
    end

    message_response = "#{added_members.length === 1 ? added_members[0] : added_members.length === 2 ? added_members.join(' and ') : added_members[0..-2].join(', ') + ' and ' + added_members[-1]} has successfully been added to the chat."
    return render json: { status: "success", message: message_response, added_members: added_members }, status: :ok
  end

  def leave
    request_body = JSON.parse(request.body.read)
    chat_id = request_body['chat_id']
    user_id = request_body['user_id']
    chat = Chat.find_by(id: chat_id)
    message = Message.create(chat_id: chat_id, user_id: user_id, message_text: "#{User.find_by(id: user_id).name} has left the chat.", event_message: true, sender: 'System')
    return render json: { status: 'failed', error: 'System message creation failed', errors: message.errors.full_messages.to_sentence }, status: :ok unless message.persisted?
    chat_member = ChatMember.find_by(chat_id: chat_id, user_id: user_id).destroy
    render json: { status: "success", message: 'Left chat successfully' }, status: :ok unless chat_member.nil?
  end

  def archive_chatmember
    request_body = JSON.parse(request.body.read)
    chat_id = request_body['chat_id']
    user_id = request_body['user_id']
    chat = Chat.joins(:chat_members).where(chat_members: {user_id: user_id}).where(id: chat_id).first
    if chat.nil?
      render json: { status: 'failed', error: 'Chat not found' }, status: :ok
    else
      Chatmember.where(chat_id: chat_id, user_id: user_id).update(archived: true)
      render json: { status: "success", message: 'Chat archived successfully' }, status: :ok
    end
  end

  private

  def chatmembers_params
    params.require(:chatmember).permit(:user_id, :chat_id, chat_members: [])
  end

  def validate_add_chat_member
    participants = chatmembers_params[:chat_members]
    chat_id = chatmembers_params[:chat_id]
    chat = Chat.find_by(id: chat_id)
    if chat.nil?
      return render json: { message: 'Chat not found' }, status: :ok
    elsif chat.chat_type == 'direct'
        return render json: { status: 'failed', error: 'Cannot add members to direct chat' }, status: :ok
    end
    participants.each do |participant|
      isAlreadyMember = ChatMember.where(chat_id: chat_id, user_id: participant).exists?
      return render json: { status: 'failed', error: "#{User.find_by(id: participant).name} is already a member of the chat" }, status: :ok if isAlreadyMember
    end
  end

  def validate_leave_chat_member
    chat_id = chatmembers_params[:chat_id]
    user_id = chatmembers_params[:user_id]
    chat = Chat.find_by(id: chat_id)
    if chat.nil?
      return render json: { message: 'Chat not found' }, status: :ok
    elsif chat.chat_type == 'direct'
        return render json: { status: 'failed', error: 'Cannot leave direct chat, you can archive it instead' }, status: :ok
    end
    isAmember = ChatMember.find_by(chat_id: chat_id, user_id: user_id).nil?
    return render json: { status: 'failed', error: 'User is not a member of the chat' }, status: :ok if isAmember
  end
end

