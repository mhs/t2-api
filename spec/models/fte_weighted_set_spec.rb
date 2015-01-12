require 'spec_helper'
require 'weighted_set'

describe FteWeightedSet do

  describe 'to_fte' do
    let(:fte_count) { fws.to_fte.to_i }

    context 'on a normal day' do
      let(:fws) { FteWeightedSet.new({ 1 => 100, 2=> 50, 3 => 25}) }

      it 'rounds down to the nearest integer' do
        expect(fte_count).to eql(1)
      end
    end

    context 'never returns less than zero' do
      let(:fws) { FteWeightedSet.new({ 1 => -100, 2=> -50, 3 => 25}) }

      it 'rounds down to the nearest integer' do
        expect(fte_count).to eql(0)
      end
    end
  end
end
