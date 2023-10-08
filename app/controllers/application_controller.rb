class ApplicationController < ActionController::API
  before_action :authenticate, except: %i[register login confirm_email resend_token forgot_password confirm_forgot_password]
  def authenticate
    unless request.headers['Authorization']
      return render json: { status: 'failed', error: 'Missing token.' },
                    status: :bad_request
    end
    token = request.headers['Authorization'].split(' ')[1]
    token_expiry = Base64.decode64(token.split('|')[0])
    request_secret = token.split('|')[1]
    token_secret = ENV['TOKEN_SECRET']
    if !token_expiry || !request_secret
      render json: { status: 'failed', error: 'Invalid token.' }, status: :bad_request
    elsif token_expiry.to_i < DateTime.now.strftime('%Y%m%d').to_i
      render json: { status: 'failed', error: 'Token expired.' }, status: :bad_request
    elsif request_secret != token_secret
      render json: { status: 'failed', error: 'Invalid token.' }, status: :bad_request
    end
  end
end
