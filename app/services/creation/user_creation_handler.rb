module Creation
  class UserCreationHandler < BaseCreationHandler
    def initialize(role:)
      @role = role
    end

    def execute(context)
        user_params = context[:user_params].slice(:email, :password, :password_confirmation)
        user_params[:role] = @role

        user = User.new(user_params)

      if user.save
        context[:user] = user
        true
      else
        fail_with!(user)
        false
      end
    end
  end
end
