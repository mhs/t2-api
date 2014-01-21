class Opportunity < ActiveRecord::Base
  before_validation :downcase_confidence
  before_validation :downcase_stage

  attr_accessible :title, :description, :stage, :confidence, :amount, :expected_date_close, :next_step

  has_many :opportunity_notes

  belongs_to :person
  belongs_to :company
  belongs_to :contact
  belongs_to :office

  validates :confidence, inclusion: { in: %w(cold warm hot) }
  validates :stage, inclusion: { in: %w(on_hold new scoped won lost rejected) }

  private

  def downcase_confidence
    self.confidence.downcase! unless self.confidence.nil?
  end

  def downcase_stage
    self.stage.downcase! unless self.stage.nil?
  end
end
