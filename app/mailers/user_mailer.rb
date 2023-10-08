class UserMailer < ApplicationMailer
    default from: "ChatScape@chatscapesystem.com"

    def welcome_email(email, name, handle, token)
        @name = name
        @handle = handle
        @token = token
        mail(to: email, subject: 'Welcome to ChatScape')
    end
end
