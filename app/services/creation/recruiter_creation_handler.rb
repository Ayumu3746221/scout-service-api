module Creation
  class RecruiterCreationHandler < BaseCreationHandler
    def execute(context)
      user = context[:user]
      company = context[:company]

      raise "User not created" unless user
      raise "Comapany not created" unless company

      recuiter = Recruiter.new(
        user_id: user.id,
        company_id: company.id,
        name: context[:recruiter_params].slice(:name)
      )

      if recuiter.save
        context[:recruiter] = recuiter
      else
        fail_with!(recuiter)
      end
    end
  end
end
