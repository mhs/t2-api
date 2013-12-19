class Opportunity < ActiveRecord::Base
  before_validation :set_default_values
  before_validation :downcase_confidence
  before_validation :downcase_stage

  before_save :set_title

  attr_accessible :title, :stage, :confidence, :amount, :expected_date_close

  has_many :opportunity_notes

  belongs_to :person
  belongs_to :company
  belongs_to :contact

  validates :confidence, inclusion: { in: %w(cold warm hot) }
  validates :stage, inclusion: { in: %w(on_hold new scoped won lost rejected) }

  private

  def set_default_values
    self.confidence ||= 'warm'
    self.stage ||= 'new'
  end

  def downcase_confidence
    self.confidence.downcase!
  end

  def downcase_stage
    self.stage.downcase!
  end

  def set_title
    self.title = "#{self.person.name}'s new opportunity" if !self.person.nil? and self.title.nil?
  end
end
