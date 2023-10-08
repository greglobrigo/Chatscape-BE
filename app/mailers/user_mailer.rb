class UserMailer < ApplicationMailer
    default from: "ChatScape@chatscapesystem.com"

    def email_message( email, name, handle, code )
        # mail(to: User.first, subject: 'test', body: "body text for mail")
        mail(to: email, subject: 'Welcome to Chatscape!', body: "Welcome to Chatscape, #{name}! Your handle is #{handle}. Your verification code is #{code}")
    end
end
