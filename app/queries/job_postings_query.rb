class JobPostingsQuery
  def initialize(relation = JobPosting.all, params = {})
    @relation = relation
    @params = params
  end

  def call
    @relation
      .active
      .then { |r| params[:skill_ids] ? r.with_skill(params[:skill_ids]) : r }
      .then { |r| params[:industry_ids] ? r.with_industry(params[:industry_ids]) : r }
      .then { |r| paginate(r) }
  end

  private

  attr_reader :params

  def paginate(relation)
    return relation unless defined?(Kaminari)
    relation.page(params[:page]).per(10)
  end
end
