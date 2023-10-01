class Chatmembers::ChatmembersController < ApplicationController
  before_action :validate, only: [:add]
  def add
    request_body = JSON.parse(request.body.read)
    user_id = request_body['user_id']
    chat_id = request_body['chat_id']
    participants = request_body['chat_members']

    return render json: { status: "failed", message: 'No members to add' }, status: :unprocessable_entity if participants.nil? || participants.length == 0

    added_members = []
    participants.each do |participant|
        member = User.find_by(id: participant)
        memberexists = !member.nil?
        return render json: { status: 'failed', message: 'Member not found' }, status: :not_found unless memberexists
        if member.handle
            added_members.push(member.handle)
        elsif member.name
            added_members.push(member.name)
        else
            added_members.push(member.email)
        end
    end


    participants.each do |participant|
      chat_member = ChatMember.create(chat_id:, user_id: participant)
      unless chat_member.persisted?
        return render json: { status: "failed", message: 'Chat creation failed', errors: chat_member.errors }, status: :unprocessable_entity
      end
    end

    Message.create(chat_id: chat_id, user_id: user_id, message_text: "#{added_members.length === 1 ? added_members[0] :
    added_members.length === 2 ? added_members.join(' and ') :
    added_members[0..-2].join(', ') + ' and ' + added_members[-1]} has been added to the chat.", event_message: true)

    return render json: { status: "success", message: 'Chat members added successfully', added_members: added_members }, status: :ok
  end

  def leave
    request_body = JSON.parse(request.body.read)
    chat_id = request_body['chat_id']
    chat = Chat.find_by(id: chat_id)
    if chat.nil?
      return render json: { message: 'Chat not found' }, status: :not_found
    elsif chat.chat_type == 'direct'
        return render json: { status: "failed", message: 'Cannot leave direct chat' }, status: :unprocessable_entity
    end

    chat_member = ChatMember.find_by(chat_id: chat_id, user_id: current_user.id)
    if chat_member.nil?
      return render json: { status: "failed", message: 'Chat member not found' }, status: :not_found
    end

    chat_member.destroy
    render json: { status: "success", message: 'Chat member deleted successfully' }, status: :ok
  end

  private

  def chatmembers_params
    params.require(:chatmember).permit(:user_id, :chat_id, chat_members: [])
  end

  def validate
    participants = chatmembers_params[:chat_members]
    chat_id = chatmembers_params[:chat_id]
    chat = Chat.find_by(id: chat_id)
    if chat.nil?
      return render json: { message: 'Chat not found' }, status: :not_found
    elsif chat.chat_type == 'direct'
        return render json: { status: "failed", message: 'Cannot add members to direct chat' }, status: :unprocessable_entity
    end
    isAlreadyMember = ChatMember.where(chat_id: chat_id, user_id: participants).exists?
    return render json: { status: "failed", message: 'A User or users you are trying to add is already a member of the chat.' }, status: :unprocessable_entity if isAlreadyMember
  end
end

