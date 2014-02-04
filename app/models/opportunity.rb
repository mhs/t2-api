class Opportunity < ActiveRecord::Base

  has_paper_trail :class_name => 'Version'

  before_validation :downcase_confidence
  before_validation :downcase_stage

  attr_accessible :title, :description, :stage, :confidence, :amount, :expected_date_close, :next_step, :status

  has_many :opportunity_notes

  belongs_to :person
  belongs_to :company
  belongs_to :contact
  belongs_to :office

  validates :confidence, inclusion: { in: %w(cold warm hot) }
  validates :stage, inclusion: { in: %w(idea contacted discovery scoped negotiation) }
  validates :status, inclusion: { in: %w(won lost rejected) }, allow_blank: true

  private

  def downcase_confidence
    confidence.downcase! if confidence
  end

  def downcase_stage
    stage.downcase! if stage
  end
end
