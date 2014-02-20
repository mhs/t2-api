require 'spec_helper'
require 'weighted_set'

describe WeightedSet do

  describe 'operations' do
    describe '-' do
      context "basic difference" do
        let(:h1) { WeightedSet.new({ 1 => 100, 2 => 50, 3 => 25 }) }
        let(:h2) { WeightedSet.new({ 2 => 25 }) }
        let(:expected) { WeightedSet.new({ 1 => 100, 2 => 25, 3 => 25 }) }

        it "should work" do
          expect(h1-h2).to eq(expected)
        end
      end

      context "difference with extras" do
        let(:h1) { WeightedSet.new({ 1 => 100, 2 => 50, 3 => 25 }) }
        let(:h2) { WeightedSet.new({ 2 => 25, 4 => 100 }) }
        let(:expected) { WeightedSet.new({ 1 => 100, 2 => 25, 3 => 25 }) }

        it "should work" do
          expect(h1-h2).to eq(expected)
        end
      end

      context "difference below zero" do
        # TODO: make sure this is correct
        let(:h1) { WeightedSet.new({ 1 => 100, 2 => 50, 3 => 25 }) }
        let(:h2) { WeightedSet.new({ 2 => 75 }) }
        let(:expected) { WeightedSet.new({ 1 => 100, 2 => -25, 3 => 25 }) }

        it "should work" do
          expect(h1-h2).to eq(expected)
        end
      end

      context "difference of exactly zero" do
        # TODO: make sure this is correct
        let(:h1) { WeightedSet.new({ 1 => 100, 2 => 50, 3 => 25 }) }
        let(:h2) { WeightedSet.new({ 2 => 50 }) }
        let(:expected) { WeightedSet.new({ 1 => 100, 2 => 0, 3 => 25 }) }

        it "should work" do
          expect(h1-h2).to eq(expected)
        end
      end
    end

    describe '+' do
      let(:h1) { WeightedSet.new({ 1 => 100, 2 => 50 }) }
      let(:h2) { WeightedSet.new({ 2 => 75, 3 => 25 }) }
      let(:expected) { WeightedSet.new({ 1 => 100, 2 => 125, 3 => 25 }) }

      it "should work" do
        expect(h1+h2).to eq(expected)
      end
    end

    describe 'total' do
      it "sums the values of its elements" do
        w = WeightedSet.new({1 => 100 , 2 => 20})
        expect(w.total).to eq 120
      end
    end

    describe 'compact' do
      it "does nothing to a set without zero elements" do
        w = WeightedSet.new({ 1 => 100 })
        expect(w.compact).to eq w
      end
      it "removes elements whose values are zero" do
        w = WeightedSet.new({1 => 100 , 2 => 0})
        expect(w.compact).to eq WeightedSet.new( {1 => 100})
      end
    end

    describe "max" do
      it "does nothing to a set with larger elements" do
        w = WeightedSet.new({ 1 => 100 })
        expect(w.max(0)).to eq w
      end

      it "changes smaller elements to the specified value" do
        w = WeightedSet.new({ 1 => 100, 2 => -20 })
        expected = WeightedSet.new({ 1 => 100, 2 => 10 })
        expect(w.max(10)).to eq expected
      end
    end

    describe "==" do
      it "considers different key orders identical" do
        w = WeightedSet.new({ 1 => 100, 2 => 75, 3 => 50 })
        w2 = WeightedSet.new({ 3 => 50, 1 => 100, 2 => 75 })
        expect(w).to eq(w2)
      end
    end
  end
end
