class Api::V1::SkillsController < ApplicationController
  def index
    @skills = Skill.all
    render json: @skills.as_json({ only: [ :id, :name ] }), status: :ok
  end
end
