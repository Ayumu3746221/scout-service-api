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
        name: context[:recruiter_params][:name]
      )

      if recuiter.save
        context[:recruiter] = recuiter
        true
      else
        fail_with!(recuiter)
        false
      end
    end
  end
end
