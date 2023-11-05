class ApplicationController < ActionController::API
  before_action :authenticate, except: %i[register login confirm_email resend_token forgot_password confirm_forgot_password admin_register]
  def authenticate
    unless request.headers['Authorization']
      return render json: { status: 'failed', error: 'Missing token.' },
                    status: :ok
    end
    token = request.headers['Authorization'].split(' ')[1]
    token_expiry = Base64.decode64(token.split('|')[0])
    request_secret = token.split('|')[1]
    token_secret = ENV['TOKEN_SECRET']
    if !token_expiry || !request_secret
      render json: { status: 'failed', error: 'Invalid token.' }, status: :ok
      #include minutes in token expiry
    elsif token_expiry.to_i < DateTime.now.strftime('%Y%m%d%H%M%S').to_i
      render json: { status: 'failed', error: 'Session expired, please login again.' }, status: :ok
    elsif request_secret != token_secret
      render json: { status: 'failed', error: 'Invalid token.' }, status: :ok
    end
  end
end
