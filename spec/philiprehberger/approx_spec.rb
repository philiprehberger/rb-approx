# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Approx do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.equal?' do
    it 'returns true for identical floats' do
      expect(described_class.equal?(1.0, 1.0)).to be true
    end

    it 'returns true for floats within epsilon' do
      expect(described_class.equal?(1.0, 1.0 + 1e-10)).to be true
    end

    it 'returns false for floats outside epsilon' do
      expect(described_class.equal?(1.0, 1.1)).to be false
    end

    it 'uses custom epsilon' do
      expect(described_class.equal?(1.0, 1.05, epsilon: 0.1)).to be true
    end

    it 'compares arrays element-wise' do
      expect(described_class.equal?([1.0, 2.0], [1.0, 2.0 + 1e-10])).to be true
    end

    it 'returns false for arrays of different length' do
      expect(described_class.equal?([1.0], [1.0, 2.0])).to be false
    end

    it 'compares hashes by value' do
      a = { x: 1.0, y: 2.0 }
      b = { x: 1.0 + 1e-10, y: 2.0 }
      expect(described_class.equal?(a, b)).to be true
    end

    it 'returns false for hashes with different keys' do
      expect(described_class.equal?({ a: 1.0 }, { b: 1.0 })).to be false
    end

    it 'handles nested arrays' do
      a = [[1.0, 2.0], [3.0]]
      b = [[1.0 + 1e-10, 2.0], [3.0]]
      expect(described_class.equal?(a, b)).to be true
    end

    it 'falls back to == for non-numeric types' do
      expect(described_class.equal?('hello', 'hello')).to be true
    end

    it 'returns true for identical integers' do
      expect(described_class.equal?(5, 5)).to be true
    end

    it 'returns false for different integers' do
      expect(described_class.equal?(5, 6)).to be false
    end

    it 'compares integer and float within epsilon' do
      expect(described_class.equal?(1, 1.0)).to be true
    end

    it 'handles zero values' do
      expect(described_class.equal?(0.0, 0.0)).to be true
    end

    it 'handles zero tolerance' do
      expect(described_class.equal?(1.0, 1.0, epsilon: 0.0)).to be true
    end

    it 'returns false for very small difference with zero tolerance' do
      expect(described_class.equal?(1.0, 1.0 + 1e-15, epsilon: 0.0)).to be false
    end

    it 'handles negative numbers' do
      expect(described_class.equal?(-1.0, -1.0 + 1e-10)).to be true
    end

    it 'handles negative and positive near zero' do
      expect(described_class.equal?(-1e-10, 1e-10)).to be true
    end

    it 'returns false for negative numbers far apart' do
      expect(described_class.equal?(-1.0, -2.0)).to be false
    end

    it 'handles very large numbers' do
      expect(described_class.equal?(1e15, 1e15 + 1e-10)).to be true
    end

    it 'handles very small numbers' do
      expect(described_class.equal?(1e-15, 2e-15, epsilon: 1e-14)).to be true
    end

    it 'handles Float::NAN (NaN is not near NaN)' do
      # NaN - NaN is NaN, .abs is NaN, NaN <= epsilon is false
      expect(described_class.equal?(Float::NAN, Float::NAN)).to be false
    end

    it 'handles Float::INFINITY' do
      # Infinity - Infinity is NaN
      expect(described_class.equal?(Float::INFINITY, Float::INFINITY)).to be false
    end

    it 'returns false for infinity vs finite' do
      expect(described_class.equal?(Float::INFINITY, 1.0)).to be false
    end

    it 'handles mixed positive and negative infinity' do
      expect(described_class.equal?(Float::INFINITY, -Float::INFINITY)).to be false
    end

    it 'returns false for non-equal strings' do
      expect(described_class.equal?('hello', 'world')).to be false
    end

    it 'handles empty arrays' do
      expect(described_class.equal?([], [])).to be true
    end

    it 'handles empty hashes' do
      expect(described_class.equal?({}, {})).to be true
    end

    it 'handles nested hashes' do
      a = { point: { x: 1.0, y: 2.0 } }
      b = { point: { x: 1.0 + 1e-10, y: 2.0 } }
      expect(described_class.equal?(a, b)).to be true
    end

    it 'returns false for hashes with different number of keys' do
      expect(described_class.equal?({ a: 1.0 }, { a: 1.0, b: 2.0 })).to be false
    end

    it 'handles large epsilon' do
      expect(described_class.equal?(0.0, 100.0, epsilon: 200.0)).to be true
    end
  end

  describe '.near?' do
    it 'behaves like equal?' do
      expect(described_class.near?(1.0, 1.0 + 1e-10)).to be true
    end

    it 'accepts custom epsilon' do
      expect(described_class.near?(1.0, 1.5, epsilon: 1.0)).to be true
    end

    it 'returns false for distant values' do
      expect(described_class.near?(1.0, 100.0)).to be false
    end
  end

  describe '.clamp' do
    it 'returns target when value is approximately equal' do
      expect(described_class.clamp(1.0 + 1e-10, 1.0)).to eq(1.0)
    end

    it 'returns value when not approximately equal' do
      expect(described_class.clamp(1.1, 1.0)).to eq(1.1)
    end

    it 'returns target for exact match' do
      expect(described_class.clamp(5.0, 5.0)).to eq(5.0)
    end

    it 'uses custom epsilon' do
      expect(described_class.clamp(1.05, 1.0, epsilon: 0.1)).to eq(1.0)
    end

    it 'returns value when outside custom epsilon' do
      expect(described_class.clamp(1.2, 1.0, epsilon: 0.1)).to eq(1.2)
    end

    it 'handles zero target' do
      expect(described_class.clamp(1e-10, 0.0)).to eq(0.0)
    end

    it 'returns value when far from zero target' do
      expect(described_class.clamp(1.0, 0.0)).to eq(1.0)
    end

    it 'handles negative values' do
      expect(described_class.clamp(-1.0 + 1e-10, -1.0)).to eq(-1.0)
    end

    it 'handles integers' do
      expect(described_class.clamp(5, 5)).to eq(5)
    end
  end

  describe '.assert_near' do
    it 'does not raise for near values' do
      expect { described_class.assert_near(1.0, 1.0 + 1e-10) }.not_to raise_error
    end

    it 'raises Error for distant values' do
      expect { described_class.assert_near(1.0, 2.0) }.to raise_error(described_class::Error)
    end

    it 'includes values in error message' do
      expect { described_class.assert_near(1.0, 2.0) }.to raise_error(/expected 1.0 to be near 2.0/)
    end

    it 'includes epsilon in error message' do
      expect { described_class.assert_near(1.0, 2.0, epsilon: 0.5) }.to raise_error(/epsilon: 0.5/)
    end

    it 'does not raise for near arrays' do
      expect { described_class.assert_near([1.0, 2.0], [1.0, 2.0 + 1e-10]) }.not_to raise_error
    end

    it 'raises Error for distant arrays' do
      expect { described_class.assert_near([1.0], [2.0]) }.to raise_error(described_class::Error)
    end

    it 'accepts custom epsilon' do
      expect { described_class.assert_near(1.0, 1.5, epsilon: 1.0) }.not_to raise_error
    end
  end

  describe '.zero?' do
    it 'returns true for exact zero' do
      expect(described_class.zero?(0.0)).to be true
    end

    it 'returns true for tiny positive value' do
      expect(described_class.zero?(1e-12)).to be true
    end

    it 'returns true for tiny negative value' do
      expect(described_class.zero?(-1e-12)).to be true
    end

    it 'returns false for larger value' do
      expect(described_class.zero?(0.1)).to be false
    end

    it 'accepts custom epsilon' do
      expect(described_class.zero?(0.05, epsilon: 0.1)).to be true
    end

    it 'returns true for integer zero' do
      expect(described_class.zero?(0)).to be true
    end
  end

  describe '.between?' do
    it 'returns true for value within range' do
      expect(described_class.between?(5.0, 1.0, 10.0)).to be true
    end

    it 'returns true for value at lower bound' do
      expect(described_class.between?(1.0, 1.0, 10.0)).to be true
    end

    it 'returns true for value at upper bound' do
      expect(described_class.between?(10.0, 1.0, 10.0)).to be true
    end

    it 'returns true for value just below lower bound within epsilon' do
      expect(described_class.between?(1.0 - 1e-10, 1.0, 10.0)).to be true
    end

    it 'returns true for value just above upper bound within epsilon' do
      expect(described_class.between?(10.0 + 1e-10, 1.0, 10.0)).to be true
    end

    it 'returns false for value clearly below range' do
      expect(described_class.between?(0.5, 1.0, 10.0)).to be false
    end

    it 'returns false for value clearly above range' do
      expect(described_class.between?(11.0, 1.0, 10.0)).to be false
    end

    it 'accepts custom epsilon' do
      expect(described_class.between?(10.5, 1.0, 10.0, epsilon: 1.0)).to be true
    end

    it 'handles negative ranges' do
      expect(described_class.between?(-5.0, -10.0, -1.0)).to be true
    end
  end

  describe '.tolerance_range' do
    it 'returns [min, max] around a value' do
      expect(described_class.tolerance_range(5.0, epsilon: 0.1)).to eq([4.9, 5.1])
    end

    it 'uses default epsilon' do
      min, max = described_class.tolerance_range(1.0)
      expect(min).to be_within(1e-15).of(1.0 - 1e-9)
      expect(max).to be_within(1e-15).of(1.0 + 1e-9)
    end

    it 'handles zero value' do
      expect(described_class.tolerance_range(0.0, epsilon: 0.5)).to eq([-0.5, 0.5])
    end

    it 'handles negative value' do
      expect(described_class.tolerance_range(-3.0, epsilon: 0.1)).to eq([-3.1, -2.9])
    end

    it 'handles integer input' do
      expect(described_class.tolerance_range(10, epsilon: 1)).to eq([9, 11])
    end

    it 'returns exact bounds with zero epsilon' do
      expect(described_class.tolerance_range(5.0, epsilon: 0.0)).to eq([5.0, 5.0])
    end
  end

  describe '.sign_equal?' do
    it 'returns true for two positive values' do
      expect(described_class.sign_equal?(5.0, 7.0)).to be true
    end

    it 'returns true for two negative values' do
      expect(described_class.sign_equal?(-2.0, -9.0)).to be true
    end

    it 'returns false for opposite signs' do
      expect(described_class.sign_equal?(2.0, -3.0)).to be false
    end

    it 'returns true when both values are near zero' do
      expect(described_class.sign_equal?(1e-12, -1e-12)).to be true
    end

    it 'returns false when one value is near zero and the other is positive' do
      expect(described_class.sign_equal?(1e-12, 2.0)).to be false
    end

    it 'returns false when one value is near zero and the other is negative' do
      expect(described_class.sign_equal?(1e-12, -2.0)).to be false
    end

    it 'accepts a custom epsilon' do
      expect(described_class.sign_equal?(0.05, -0.05, epsilon: 0.1)).to be true
    end

    it 'handles integer inputs' do
      expect(described_class.sign_equal?(3, 4)).to be true
    end

    it 'handles negative integer inputs' do
      expect(described_class.sign_equal?(-3, -4)).to be true
    end

    it 'returns false for integers with opposite signs' do
      expect(described_class.sign_equal?(3, -4)).to be false
    end
  end

  describe '.assert_within' do
    it 'does not raise when within absolute tolerance' do
      expect { described_class.assert_within(1.0, 1.0001, abs: 0.001) }.not_to raise_error
    end

    it 'does not raise when within relative tolerance' do
      expect { described_class.assert_within(1_000_000.0, 1_000_001.0, rel: 1e-5) }.not_to raise_error
    end

    it 'raises Error when outside both tolerances' do
      expect { described_class.assert_within(1.0, 2.0, abs: 0.01, rel: 1e-9) }
        .to raise_error(described_class::Error)
    end

    it 'raises ArgumentError when no tolerance provided' do
      expect { described_class.assert_within(1.0, 1.0) }.to raise_error(ArgumentError)
    end

    it 'includes values in error message' do
      expect { described_class.assert_within(1.0, 2.0, abs: 0.01) }
        .to raise_error(/expected 1.0 to be within 2.0/)
    end
  end

  describe '.percent_equal?' do
    it 'returns true when within percentage tolerance' do
      expect(described_class.percent_equal?(100.0, 105.0, percent: 10)).to be true
    end

    it 'returns false when outside percentage tolerance' do
      expect(described_class.percent_equal?(100.0, 115.0, percent: 10)).to be false
    end

    it 'returns true when both values are zero' do
      expect(described_class.percent_equal?(0.0, 0.0, percent: 5)).to be true
    end

    it 'handles negative values' do
      expect(described_class.percent_equal?(-100.0, -105.0, percent: 10)).to be true
    end

    it 'returns false for negative values outside tolerance' do
      expect(described_class.percent_equal?(-100.0, -120.0, percent: 10)).to be false
    end

    it 'compares arrays element-wise' do
      expect(described_class.percent_equal?([100.0, 200.0], [105.0, 210.0], percent: 10)).to be true
    end

    it 'returns false for arrays with mismatched element' do
      expect(described_class.percent_equal?([100.0, 200.0], [105.0, 250.0], percent: 10)).to be false
    end

    it 'compares hashes by value' do
      a = { x: 100.0, y: 200.0 }
      b = { x: 105.0, y: 195.0 }
      expect(described_class.percent_equal?(a, b, percent: 10)).to be true
    end

    it 'returns false for hashes with different keys' do
      expect(described_class.percent_equal?({ a: 100.0 }, { b: 100.0 }, percent: 10)).to be false
    end
  end

  describe '.diff' do
    it 'returns a hash with correct keys' do
      result = described_class.diff(1.0, 2.0)
      expect(result).to include(:match, :actual_diff, :allowed, :ratio)
    end

    it 'returns match: true when values are within epsilon' do
      result = described_class.diff(1.0, 1.0, epsilon: 0.1)
      expect(result[:match]).to be true
    end

    it 'returns match: false when values differ beyond epsilon' do
      result = described_class.diff(1.0, 2.0, epsilon: 0.1)
      expect(result[:match]).to be false
    end

    it 'computes correct actual_diff' do
      result = described_class.diff(3.0, 5.0, epsilon: 1.0)
      expect(result[:actual_diff]).to be_within(1e-12).of(2.0)
    end

    it 'computes correct ratio' do
      result = described_class.diff(1.0, 1.5, epsilon: 1.0)
      expect(result[:ratio]).to be_within(1e-12).of(0.5)
    end

    it 'returns infinity ratio when epsilon is zero' do
      result = described_class.diff(1.0, 2.0, epsilon: 0.0)
      expect(result[:ratio]).to eq(Float::INFINITY)
    end
  end

  describe Philiprehberger::Approx::RSpecMatchers do
    include described_class

    describe '#be_approx' do
      it 'passes for approximately equal values' do
        expect(1.0).to be_approx(1.0 + 1e-16)
      end

      it 'fails for values outside epsilon' do
        expect(1.0).not_to be_approx(2.0)
      end

      it 'supports custom epsilon' do
        expect(1.0).to be_approx(1.05, epsilon: 0.1)
      end
    end

    describe '#be_approx_within' do
      it 'passes with absolute tolerance' do
        expect(1.0).to be_approx_within(1.005, abs: 0.01)
      end

      it 'passes with relative tolerance' do
        expect(1_000_000.0).to be_approx_within(1_000_001.0, rel: 1e-5)
      end

      it 'passes with percent tolerance' do
        expect(100.0).to be_approx_within(105.0, percent: 10)
      end

      it 'fails when outside tolerance' do
        expect(1.0).not_to be_approx_within(2.0, abs: 0.01)
      end
    end
  end

  describe Philiprehberger::Approx::Comparator do
    describe '#near?' do
      it 'matches #equal?' do
        comparator = described_class.new(epsilon: 0.01)
        expect(comparator.near?(1.0, 1.005)).to be true
      end
    end

    describe '#within?' do
      it 'passes via absolute tolerance' do
        comparator = described_class.new(epsilon: 0.01, relative: 1e-9)
        expect(comparator.within?(0.001, 0.002)).to be true
      end

      it 'passes via relative tolerance' do
        comparator = described_class.new(epsilon: 1e-9, relative: 1e-5)
        expect(comparator.within?(1_000_000.0, 1_000_001.0)).to be true
      end

      it 'returns false when neither tolerance is met' do
        comparator = described_class.new(epsilon: 1e-9, relative: 1e-9)
        expect(comparator.within?(1.0, 2.0)).to be false
      end
    end
  end

  describe 'rel_tol option' do
    it 'preserves default behavior when rel_tol is omitted' do
      expect(described_class.equal?(1.0, 1.0 + 1e-10)).to be true
      expect(described_class.equal?(1.0, 1.1)).to be false
    end

    it 'treats rel_tol: 0 as identical to prior behavior' do
      expect(described_class.equal?(1.0, 1.0 + 1e-10, rel_tol: 0)).to be true
      expect(described_class.equal?(1.0, 1.1, rel_tol: 0)).to be false
    end

    it 'allows 1e12 vs 1e12 + 1e9 within 1 percent' do
      expect(described_class.equal?(1e12, 1e12 + 1e9, rel_tol: 0.01)).to be true
    end

    it 'rejects 1 vs 2 at rel_tol: 0.01' do
      expect(described_class.equal?(1.0, 2.0, rel_tol: 0.01)).to be false
    end

    it 'combines rel_tol with epsilon, passing via epsilon at small magnitudes' do
      # 1e-20 vs 2e-20: rel diff is 0.5 (rel_tol 0.01 fails), but abs diff 1e-20 <= 1e-9.
      expect(described_class.equal?(1e-20, 2e-20, epsilon: 1e-9, rel_tol: 0.01)).to be true
    end

    it 'propagates rel_tol into array comparisons' do
      a = [1e12, 2e12]
      b = [1e12 + 1e9, 2e12 + 2e9]
      expect(described_class.equal?(a, b, rel_tol: 0.01)).to be true
    end

    it 'rejects array elements that exceed rel_tol' do
      expect(described_class.equal?([1e12, 1.0], [1e12 + 1e9, 2.0], rel_tol: 0.01)).to be false
    end

    it 'propagates rel_tol into hash comparisons' do
      a = { distance: 1e12, duration: 1e9 }
      b = { distance: 1e12 + 1e9, duration: 1e9 + 1e6 }
      expect(described_class.equal?(a, b, rel_tol: 0.01)).to be true
    end

    it 'propagates rel_tol recursively into nested hashes' do
      a = { nested: { value: 1e12 } }
      b = { nested: { value: 1e12 + 1e9 } }
      expect(described_class.equal?(a, b, rel_tol: 0.01)).to be true
    end

    it 'is honored by .near?' do
      expect(described_class.near?(1e12, 1e12 + 1e9, rel_tol: 0.01)).to be true
    end

    it 'is honored by .clamp' do
      expect(described_class.clamp(1e12 + 1e9, 1e12, rel_tol: 0.01)).to eq(1e12)
    end

    it 'is honored by .assert_near' do
      expect { described_class.assert_near(1e12, 1e12 + 1e9, rel_tol: 0.01) }.not_to raise_error
    end

    it 'rejects NaN even with rel_tol set' do
      expect(described_class.equal?(Float::NAN, Float::NAN, rel_tol: 0.5)).to be false
    end

    describe 'RSpec matcher' do
      include Philiprehberger::Approx::RSpecMatchers

      it 'accepts rel_tol: on be_approx' do
        expect(1e12).to be_approx(1e12 + 1e9, rel_tol: 0.01)
      end

      it 'fails be_approx when rel_tol is exceeded' do
        expect(1.0).not_to be_approx(2.0, rel_tol: 0.01)
      end
    end
  end
end
