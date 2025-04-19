module Creation
  class CompanyCreationHandler < BaseCreationHandler
    def execute(context)
      company = Company.new(context[:company_params].slice(:name, :email, :industry_id))
      if company.save
        context[:company] = company
        true
      else
        fail_with!(company)
        false
      end
    end
  end
end
