class Users::UsersController < ApplicationController
    def register
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        password = request_body["password"]
        password_confirmation = request_body["password_confirmation"]
        if password == password_confirmation
            salt = ENV["SALT"]
            password = Base64.encode64(password + salt)
            user = User.new(email: email, password: password)
            if user.save
                render json: { status: "success", message: "Registration Successful!" }, status: :ok
            else
                render json: { status: 'failed', error: user.errors.full_messages.to_sentence }, status: :bad_request
            end
        else
            render json: { status: 'failed', error: "Password and Password Confirmation do not match." }, status: :bad_request
        end
    end

    def login
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        password = request_body["password"]
        salt = ENV["SALT"]
        password = Base64.encode64(password + salt)
        user = User.find_by(email: email, password: password)
        if user
            date_now = DateTime.now + 1.week
            date_now = date_now.strftime('%Y%m%d').to_s
            token = Base64.encode64(date_now).gsub("\n", "")
            render json: { status: "success", message: "Login Successful", token: token, user: user.id}, status: :ok
        else
            render json: { status: 'failed', error: "Invalid email or password." }, status: :bad_request
        end
    end

    def search_users_all_or_direct
        request_body = JSON.parse(request.body.read)
        user_id = request_body['user_id']
        search_string = request_body['search_string']
        users = User.where('email LIKE ?', "%#{search_string}%").or(User.where('handle LIKE ?', "%#{search_string}%")).or(User.where('name LIKE ?', "%#{search_string}%"))
        .where.not(id: user_id).where.not(id: User.joins(:chats).where(chats: { chat_type: 'direct' }).where('chat_members.user_id = ?', user_id)).limit(10)
        users = users.map { |user| { id: user.id, email: user.email, handle: user.handle, name: user.name } }
        if users.length == 0
            render json: { status: "success", message: 'No User Found' }, status: :ok
        else
            render json: { status: "success", message: 'Users found', users: users }, status: :ok
        end
    end

    def search_users_group
        request_body = JSON.parse(request.body.read)
        user_id = request_body['user_id']
        search_string = request_body['search_string']
        users = User.where('email LIKE ?', "%#{search_string}%").or(User.where('handle LIKE ?', "%#{search_string}%")).or(User.where('name LIKE ?', "%#{search_string}%"))
        .where.not(id: user_id).where.not(id: User.joins(:chats).where(chats: { chat_type: 'group' }).where('chat_members.user_id = ?', user_id)).limit(10)
        users = users.map { |user| { id: user.id, email: user.email, handle: user.handle, name: user.name } }
        if users.length == 0
            render json: { status: "success", message: 'No User Found' }, status: :ok
        else
            render json: { status: "success", message: 'Users found', users: users }, status: :ok
        end
    end

    def search_users_public
        request_body = JSON.parse(request.body.read)
        user_id = request_body['user_id']
        search_string = request_body['search_string']
        users = User.where('email LIKE ?', "%#{search_string}%").or(User.where('handle LIKE ?', "%#{search_string}%")).or(User.where('name LIKE ?', "%#{search_string}%"))
        .where.not(id: user_id).where.not(id: User.joins(:chats).where(chats: { chat_type: 'public' }).where('chat_members.user_id = ?', user_id)).limit(10)
        users = users.map { |user| { id: user.id, email: user.email, handle: user.handle, name: user.name } }
        if users.length == 0
            render json: { status: "success", message: 'No User Found' }, status: :ok
        else
            render json: { status: "success", message: 'Users found', users: users }, status: :ok
        end
    end

    def get_profile
        request_body = JSON.parse(request.body.read)
        user_id = request_body['user_id']
        user = User.find_by(id: user_id)
        user = { id: user.id, email: user.email, handle: user.handle, name: user.name }

        return render json: { status: 'failed', error: "User not found" }, status: :bad_request unless user

        direct_chats = Chat.joins(:chat_members)
                                             .where(chat_members: { user_id: user_id }, chat_type: 'direct')
                                             .order(updated_at: :desc)
                                             .includes(:messages).limit(10)
                                             .map { |chat| chat.as_json(include: { messages: { except: [:created_at, :updated_at] } }, except: [:created_at, :updated_at]) }

        group_chats = Chat.joins(:chat_members)
                                            .where(chat_members: { user_id: user_id }, chat_type: 'group')
                                            .order(updated_at: :desc)
                                            .includes(:messages).limit(10)
                                            .map { |chat| chat.as_json(include: { messages: { except: [:created_at, :updated_at] } }, except: [:created_at, :updated_at]) }

        public_chats = Chat.where(chat_type: 'public')
                                             .order(updated_at: :desc)
                                             .includes(:messages).limit(10)
                                             .map { |chat| chat.as_json(include: { messages: { except: [:created_at, :updated_at] } }, except: [:created_at, :updated_at]) }

        direct_chats.each { |chat| chat['messages'] = chat['messages'].last() }
        group_chats.each { |chat| chat['messages'] = chat['messages'].last() }
        public_chats.each { |chat| chat['messages'] = chat['messages'].last() }

        render json: { user: user, direct_chats: direct_chats, group_chats: group_chats, public_chats: public_chats }, status: :ok
    end
end