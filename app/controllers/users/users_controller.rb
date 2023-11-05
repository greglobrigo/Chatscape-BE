class Users::UsersController < ApplicationController
    def register
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        password = request_body["password"]
        password_confirmation = request_body["password_confirmation"]
        name = request_body["name"] || ""
        handle = request_body["handle"] || ""
        avatar = request_body["avatar"] || ""
        if password == password_confirmation
            salt = ENV["SALT"]
            password = Base64.encode64(password + salt)
            auth_token = generate_token
            user = User.new(email: email, password: password, auth_token: auth_token, status: 'unauthenticated', name: name, handle: handle, avatar: avatar)
            if user.save
                mailer = UserMailer.email_message(email, name, handle, auth_token).deliver_later
                render json: { status: "success", message: "Registration Successful!", system: "An email has been sent to #{email} with a code to verify your account."}, status: :ok
            else
                render json: { status: 'failed', error: user.errors.full_messages.to_sentence }, status: :ok
            end
        else
            render json: { status: 'failed', error: "Password and Password Confirmation do not match." }, status: :ok
        end
    end

    def admin_register
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        password = request_body["password"]
        salt = ENV["SALT"]
        name = request_body["name"] || ""
        handle = request_body["handle"] || ""
        auth_token = generate_token
        password = Base64.encode64(password + salt)
        admin_secret = ENV["ADMIN_SECRET"]
        return render json: { status: 'failed', error: "Invalid request." }, status: :ok if email == nil || password == nil || name == nil || handle == nil || auth_token == nil || admin_secret == nil
        return render json: { status: 'failed', error: "Invalid request." }, status: :ok if request_body["admin_secret"] != admin_secret
        user = User.new(email: email, password: password, auth_token: auth_token, status: 'active', name: name, handle: handle)
        if user.save
            render json: { status: "success", message: "Admin Registration Successful!"}, status: :ok
        else
            render json: { status: 'failed', error: user.errors.full_messages.to_sentence }, status: :ok
        end
    end

    def validate
        request_body = JSON.parse(request.body.read)
        user_id = request_body["user_id"]
        user = User.find_by(id: user_id)
        if user
            render json: { status: "success" }, status: :ok
        else
            render json: { status: 'failed', error: "Error validating session." }, status: :ok
        end
    end

    def login
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        password = request_body["password"]
        salt = ENV["SALT"]
        password = Base64.encode64(password + salt)
        user = User.find_by(email: email, password: password)
        return render json: { status: 'failed', error: "Invalid email or password." }, status: :ok unless user
        user_status = user.status
        if user && user_status === 'active'
            date_now = DateTime.now + 1.week
            date_now = date_now.strftime('%Y%m%d%H%M%S').to_s
            token = Base64.encode64(date_now).gsub("\n", "")
            user.update(updated_at: DateTime.now)
            render json: { status: "success", message: "Login Successful! Redirecting...", token: token, user: user.id}, status: :ok
        elsif user && user_status === 'unauthenticated'
            render json: {status: 'success', message: "For email validation"}, status: :ok
        end
    end

    def confirm_email
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        auth_token = request_body["auth_token"]
        user = User.find_by(email: email)
        return render json: { status: 'failed', error: "Invalid request." }, status: :ok if user.status == 'active' || user.nil?
        if user.auth_token == auth_token
            user.update(status: 'active')
            render json: { status: "success", message: "Email Confirmed!" }, status: :ok
        else
            render json: { status: 'failed', error: "Invalid token, please try again." }, status: :ok
        end
    end

    def resend_token
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        user = User.find_by(email: email)
        return render json: { status: 'failed', error: "Invalid request." }, status: :ok if user.status == 'active' || user.nil?
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
            return render json: { status: 'failed', error: "Invalid request" }, status: :ok
        end

        if old_password == new_password
            return render json: { status: 'failed', error: "New password cannot be the same as old password." }, status: :ok
        end

        salt = ENV["SALT"]
        old_password = Base64.encode64(old_password + salt)
        new_password = Base64.encode64(new_password + salt)
        user = User.find_by(id: user_id, password: old_password)
        if user
            user.update(password: new_password)
            render json: { status: "success", message: "Password Changed Successfully!" }, status: :ok
        else
            render json: { status: 'failed', error: "Invalid old password." }, status: :ok
        end
    end

    def forgot_password
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        user = User.find_by(email: email)
        return render json: { status: 'success', message: "An email containing a verification code has been sent to your email." }, status: :ok if user.nil?
        forgot_password_token = generate_token_fp
        user.update(forgot_password_token: forgot_password_token)
        mailer = UserMailer.forgot_password(email, user.name, user.handle, forgot_password_token).deliver_later
        render json: { status: "success", message: "A password reset code has been sent to #{email}." }, status: :ok
    end

    def confirm_forgot_password
        request_body = JSON.parse(request.body.read)
        email = request_body["email"]
        forgot_password_token = request_body["forgot_password_token"]
        user = User.find_by(email: email)
        return render json: { status: 'failed', error: "Invalid request." }, status: :ok if user.nil?
        return render json: { status: 'failed', error: "Invalid token." }, status: :ok if user.forgot_password_token != forgot_password_token
        new_password = request_body["new_password"]
        new_password_confirmation = request_body["new_password_confirmation"]
        return render json: { status: 'failed', error: "Passwords do not match." }, status: :ok if new_password != new_password_confirmation
        salt = ENV["SALT"]
        new_password = Base64.encode64(new_password + salt)
        user.update(password: new_password, forgot_password_token: nil)
        render json: { status: "success", message: "Password Changed Successfully! Redirecting to login page." }, status: :ok
    end

    def search_users_all_or_direct
        request_body = JSON.parse(request.body.read)
        user_id = request_body['user_id']
        search_string = request_body['search_string']
        users = User.where('email LIKE ?', "%#{search_string}%").or(User.where('handle LIKE ?', "%#{search_string}%")).or(User.where('name LIKE ?', "%#{search_string}%"))
        .where.not(id: user_id).where.not(id: User.joins(:chats).where(chats: { chat_type: 'direct' }).where('chat_members.user_id = ?', user_id)).limit(10)
        users = users.map { |user| { id: user.id, email: user.email, handle: user.handle, name: user.name, avatar: user.avatar, updated_at: user.updated_at } }
        if users.length == 0
            render json: { status: "success", message: 'No User Found', users: [] }, status: :ok
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
        users = users.map { |user| { id: user.id, email: user.email, handle: user.handle, name: user.name, avatar: user.avatar } }
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
        users = users.map { |user| { id: user.id, email: user.email, handle: user.handle, name: user.name, avatar: user.avatar } }
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
        return render json: { status: 'failed', error: "User not found" }, status: :ok unless user
        user = { id: user.id, email: user.email, handle: user.handle, name: user.name, avatar: user.avatar }

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

        # direct_chats = Chat.joins(:chat_members)
        #                                      .where(chat_members: { user_id: user_id, archived: false }, chat_type: 'direct')
        #                                      .order(updated_at: :desc)
        #                                      .includes(:messages).limit(10)
        #                                      .map { |chat| chat.as_json(include: { messages: { except: [:created_at, :updated_at] } }, except: [:created_at, :updated_at]) }

        # group_chats = Chat.joins(:chat_members)
        #                                     .where(chat_members: { user_id: user_id, archived: false }, chat_type: 'group')
        #                                     .order(updated_at: :desc)
        #                                     .includes(:messages).limit(10)
        #                                     .map { |chat| chat.as_json(include: { messages: { except: [:created_at, :updated_at] } }, except: [:created_at, :updated_at]) }

        # public_chats = Chat.joins(:chat_members)
        #                                      .where(chat_members: { user_id: user_id, archived: false }, chat_type: 'public')
        #                                      .order(updated_at: :desc)
        #                                      .includes(:messages).limit(10)
        #                                      .map { |chat| chat.as_json(include: { messages: { except: [:created_at, :updated_at] } }, except: [:created_at, :updated_at]) }

        # direct_chats.each { |chat| chat['messages'] = chat['messages'].last() }
        # group_chats.each { |chat| chat['messages'] = chat['messages'].last() }
        # public_chats.each { |chat| chat['messages'] = chat['messages'].last() }

        active_users = User.where.not(id: user_id).where.not(status: 'unauthenticated').order(updated_at: :desc).limit(30).map { |user| { id: user.id, email: user.email, handle: user.handle, name: user.name, avatar: user.avatar, updated_at: user.updated_at } }

        # render json: { user: user, direct_chats: direct_chats, group_chats: group_chats, public_chats: public_chats, active_users: active_users }, status: :ok
        render json: { status: "success", user: user, chats: chats, active_users: active_users }, status: :ok
    end

    private

    def generate_token
        SecureRandom.alphanumeric(5)
    end

    def generate_token_fp
        SecureRandom.alphanumeric(12)
    end
end
