class Api::V1::IndustriesController < ApplicationController
  def index
    @industries = Industry.all
    render json: @industries.as_json(only: [ :id, :name ]), status: :ok
  end
end
