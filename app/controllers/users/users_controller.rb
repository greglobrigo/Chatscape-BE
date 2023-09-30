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
            render json: { status: "success", message: "Login Successful", token: token }, status: :ok
        else
            render json: { status: "failed", error: "Invalid email or password." }, status: :bad_request
        end
    end
end