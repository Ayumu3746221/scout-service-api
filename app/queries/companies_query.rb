class CompaniesQuery
  def initialize(relation = Company.all, params = {})
    @relation = relation
    @params = params
  end

  def call
    @relation
      .then { |r| params[:industry_id] ? r.with_industry(params[:industry_id]) : r }
      .then { |r| paginate(r) }
  end

  private

  attr_reader :params

  def paginate(relation)
    return relation unless defined?(Kaminari)
    relation.page(params[:page]).per(10)
  end
end
