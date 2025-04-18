module AuthenticationConcern
  extend ActiveSupport::Concern

  def authenticate_user!
    unless user_signed_in?
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_company
    token = request.headers["Authorization"]&.split(" ")&.last
    return nil unless token
    begin
      secret = Rails.application.credentials.secret_key_base
      payload = JWT.decode(token, secret, true, { algorithm: "HS256" }).first
      Company.find_by(id: payload["company_id"])
    rescue JWT::DecodeError
      nil
    end
  end
end
