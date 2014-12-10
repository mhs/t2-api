require 'spec_helper'

describe Reports::Revenue do
  describe 'accepts start and end date' do
    let(:report) { Reports::Revenue.new(Date.today - 3.months, Date.today - 2.months) }

    it 'calculates range start date' do
      expect(report.start_date).to eq(Date.today - 9.months)
    end

    it 'calculates range end date' do
      expect(report.end_date).to eq(Date.today - 2.months)
    end
  end

  describe 'no start and end date parameters' do
    let(:report) { Reports::Revenue.new(nil, nil) }

    it 'calculates range start date' do
      expect(report.start_date).to eq(Date.today.beginning_of_month - 6.months)
    end

    it 'calculates range end date' do
      expect(report.end_date).to eq(Date.today.end_of_month + 36.months)
    end
  end
end
