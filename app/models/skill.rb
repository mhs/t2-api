class Skill

  include ActiveModel::SerializerSupport

  def initialize(tag)
    @tag = tag
  end

  def self.all
    Person.tag_counts_on(:skills).map do |tag|
      new(tag)
    end
  end

  def people
    Person.tagged_with(name, on: :skills)
  end

  def tag
    @tag
  end

  def count
    @tag.count
  end

  def name
    @tag.name
  end
end
