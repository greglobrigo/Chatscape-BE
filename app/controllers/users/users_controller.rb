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
                render json: { status: "failed", error: user.errors.full_messages.to_sentence }, status: :bad_request
            end
        else
            render json: { status: "failed", error: "Password and Password Confirmation do not match." }, status: :bad_request
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
            render json: { status: "failed", error: "Invalid email or password." }, status: :bad_request
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
end