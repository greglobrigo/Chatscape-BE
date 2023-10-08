class Users::UsersController < ApplicationController
    def register
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        password = request_body["password"]
        password_confirmation = request_body["password_confirmation"]
        name = request_body["name"] || ""
        handle = request_body["handle"] || ""
        if password == password_confirmation
            salt = ENV["SALT"]
            password = Base64.encode64(password + salt)
            auth_token = generate_token
            user = User.new(email: email, password: password, auth_token: auth_token, status: 'unauthenticated')
            if user.save
                mailer = UserMailer.email_message(email, name, handle, auth_token).deliver_later
                render json: { status: "success", message: "Registration Successful!", system: "An email has been sent to #{email} with a code to verify your account."}, status: :ok
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
        return render json: { status: 'failed', error: "Invalid email or password." }, status: :bad_request unless user
        user_status = user.status
        if user && user_status === 'active'
            date_now = DateTime.now + 1.week
            date_now = date_now.strftime('%Y%m%d').to_s
            token = Base64.encode64(date_now).gsub("\n", "")
            user.update(updated_at: DateTime.now)
            render json: { status: "success", message: "Login Successful", token: token, user: user.id}, status: :ok
        elsif user && user_status === 'unauthenticated'
            render json: {status: 'success', authentication: "for email validation"}, status: :ok
        end
    end

    def confirm_email
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        auth_token = request_body["auth_token"]
        user = User.find_by(email: email)
        return render json: { status: 'failed', error: "Invalid request." }, status: :bad_request if user.status == 'active' || user.nil?
        if user.auth_token == auth_token
            user.update(status: 'active')
            render json: { status: "success", message: "Email Confirmed!" }, status: :ok
        else
            render json: { status: 'failed', error: "Invalid token, please try again." }, status: :bad_request
        end
    end

    def resend_token
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        user = User.find_by(email: email)
        return render json: { status: 'failed', error: "Invalid request." }, status: :bad_request if user.status == 'active' || user.nil?
        auth_token = generate_token
        user.update(auth_token: auth_token)
        mailer = UserMailer.resend_token(email, user.name, user.handle, auth_token).deliver_later
        render json: { status: "success", message: "A new token has been sent your email #{email}." }, status: :ok
    end


    def change_password
        request_body = JSON.parse(request.body.read)
        user_id = request_body["user_id"]
        old_password = request_body["old_password"]
        new_password = request_body["new_password"]

        if user_id == nil || old_password == nil || new_password == nil
            return render json: { status: 'failed', error: "Invalid request" }, status: :bad_request
        end

        if old_password == new_password
            return render json: { status: 'failed', error: "New password cannot be the same as old password." }, status: :bad_request
        end

        salt = ENV["SALT"]
        old_password = Base64.encode64(old_password + salt)
        new_password = Base64.encode64(new_password + salt)
        user = User.find_by(id: user_id, password: old_password)
        if user
            user.update(password: new_password)
            render json: { status: "success", message: "Password Changed Successfully!" }, status: :ok
        else
            render json: { status: 'failed', error: "Invalid old password." }, status: :bad_request
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
                                             .where(chat_members: { user_id: user_id, archived: false }, chat_type: 'direct')
                                             .order(updated_at: :desc)
                                             .includes(:messages).limit(10)
                                             .map { |chat| chat.as_json(include: { messages: { except: [:created_at, :updated_at] } }, except: [:created_at, :updated_at]) }

        group_chats = Chat.joins(:chat_members)
                                            .where(chat_members: { user_id: user_id, archived: false }, chat_type: 'group')
                                            .order(updated_at: :desc)
                                            .includes(:messages).limit(10)
                                            .map { |chat| chat.as_json(include: { messages: { except: [:created_at, :updated_at] } }, except: [:created_at, :updated_at]) }

        public_chats = Chat.joins(:chat_members)
                                             .where(chat_members: { user_id: user_id, archived: false }, chat_type: 'public')
                                             .order(updated_at: :desc)
                                             .includes(:messages).limit(10)
                                             .map { |chat| chat.as_json(include: { messages: { except: [:created_at, :updated_at] } }, except: [:created_at, :updated_at]) }

        direct_chats.each { |chat| chat['messages'] = chat['messages'].last() }
        group_chats.each { |chat| chat['messages'] = chat['messages'].last() }
        public_chats.each { |chat| chat['messages'] = chat['messages'].last() }

        active_users = User.order(updated_at: :desc).limit(30).map { |user| { id: user.id, email: user.email, handle: user.handle, name: user.name } }

        render json: { user: user, direct_chats: direct_chats, group_chats: group_chats, public_chats: public_chats, active_users: active_users }, status: :ok
    end

    private

    def generate_token
        SecureRandom.alphanumeric(5)
    end
end