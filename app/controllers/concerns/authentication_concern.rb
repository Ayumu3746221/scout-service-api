module AuthenticationConcern
  extend ActiveSupport::Concern

  def authenticate_user!
    unless user_signed_in?
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
