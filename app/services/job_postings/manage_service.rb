class JobPostings::ManageService
  def initialize(company:, params:)
    @company = company
    @params  = params.require(:job_posting).permit(
      :title, :description, :requirements, :is_active,
      skill_ids: [], industry_ids: []
    )
  end

  def create
    JobPosting.transaction do
      jp = @company.job_postings.create!(@params.except(:skill_ids, :industry_ids))
      jp.skill_ids    = @params[:skill_ids]    if @params[:skill_ids]
      jp.industry_ids = @params[:industry_ids] if @params[:industry_ids]
      jp
    end
  end

  def update(job_posting)
    JobPosting.transaction do
      job_posting.update!(@params.except(:skill_ids, :industry_ids))
      job_posting.skill_ids    = @params[:skill_ids]    if @params[:skill_ids]
      job_posting.industry_ids = @params[:industry_ids] if @params[:industry_ids]
      job_posting
    end
  end
end
