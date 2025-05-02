# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RackSessionFix
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    response_data = {
      message: "Logged in successfully.",
      user: resource.as_json(only: [ :id, :email, :role ])
    }

    if resource.recruiter? && resource.jwt_payload[:company_id].present?
      response_data[:user][:company] = resource.jwt_payload[:company_id]
    end

    render json: response_data, status: :ok
  end

  def respond_to_on_destroy
    current_user ? log_out_success : log_out_failure
  end

  def log_out_success
    render json: {
      message: "Logged out successfully."
    }, status: :ok
  end

  def log_out_failure
    render json: {
      message: "Logged out failure."
    }, status: :unauthorized
  end
end
