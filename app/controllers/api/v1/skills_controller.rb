class Api::V1::SkillsController < ApplicationController

  # GET /api/v1/skills
  #
  # [
  #    {
  #        "name": "Ruby",
  #        "count": 2,
  #        "people": [
  #            { "id": "1,", "name": "Federico Bana", "fede@neo.com", "office_name": "Montevideo" },
  #            { "id": "2,", "name": "Alvaro Gil", "alvaro@neo.com", "office_name": "Montevideo" }
  #        ]
  #    }, { ... }
  # ]
  #
  def index
    render json: Skill.all, each_serializer: SkillSerializer, root: false
  end
end
