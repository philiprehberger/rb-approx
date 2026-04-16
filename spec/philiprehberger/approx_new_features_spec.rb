# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Approx do
  describe '.relative_equal?' do
    context 'with large numbers' do
      it 'returns true for values within relative tolerance' do
        expect(described_class.relative_equal?(1_000_000.0, 1_000_001.0, tolerance: 1e-5)).to be true
      end

      it 'returns false for values outside relative tolerance' do
        expect(described_class.relative_equal?(1_000_000.0, 1_100_000.0, tolerance: 1e-5)).to be false
      end

      it 'handles large numbers that differ by a tiny fraction' do
        expect(described_class.relative_equal?(1e12, 1e12 + 1.0, tolerance: 1e-6)).to be true
      end
    end

    context 'with small numbers near zero' do
      it 'returns true for both zeros' do
        expect(described_class.relative_equal?(0.0, 0.0)).to be true
      end

      it 'returns false when one value is zero and the other is not' do
        expect(described_class.relative_equal?(0.0, 1e-10)).to be false
      end

      it 'handles very small non-zero values' do
        expect(described_class.relative_equal?(1e-10, 1.001e-10, tolerance: 0.01)).to be true
      end
    end

    context 'with negative numbers' do
      it 'returns true for negative values within tolerance' do
        expect(described_class.relative_equal?(-100.0, -100.001, tolerance: 1e-4)).to be true
      end

      it 'returns false for negative values outside tolerance' do
        expect(described_class.relative_equal?(-100.0, -200.0, tolerance: 1e-4)).to be false
      end
    end

    context 'with special values' do
      it 'returns false for NaN comparisons' do
        expect(described_class.relative_equal?(Float::NAN, Float::NAN)).to be false
      end

      it 'returns false for Infinity comparisons' do
        expect(described_class.relative_equal?(Float::INFINITY, Float::INFINITY)).to be false
      end

      it 'returns false for Infinity vs finite' do
        expect(described_class.relative_equal?(Float::INFINITY, 1.0)).to be false
      end

      it 'returns false for mixed infinities' do
        expect(described_class.relative_equal?(Float::INFINITY, -Float::INFINITY)).to be false
      end
    end

    context 'with arrays' do
      it 'compares arrays element-wise with relative tolerance' do
        expect(described_class.relative_equal?([1_000.0, 2_000.0], [1_000.5, 2_001.0], tolerance: 1e-3)).to be true
      end

      it 'returns false for arrays of different length' do
        expect(described_class.relative_equal?([1.0], [1.0, 2.0])).to be false
      end

      it 'handles empty arrays' do
        expect(described_class.relative_equal?([], [])).to be true
      end
    end

    context 'with hashes' do
      it 'compares hashes by value with relative tolerance' do
        a = { x: 1_000.0, y: 2_000.0 }
        b = { x: 1_000.5, y: 2_001.0 }
        expect(described_class.relative_equal?(a, b, tolerance: 1e-3)).to be true
      end

      it 'returns false for hashes with different keys' do
        expect(described_class.relative_equal?({ a: 1.0 }, { b: 1.0 })).to be false
      end

      it 'handles nested hashes' do
        a = { point: { x: 1_000.0, y: 2_000.0 } }
        b = { point: { x: 1_000.5, y: 2_001.0 } }
        expect(described_class.relative_equal?(a, b, tolerance: 1e-3)).to be true
      end
    end

    it 'uses default tolerance of 1e-6' do
      expect(described_class.relative_equal?(1.0, 1.0 + 5e-7)).to be true
      expect(described_class.relative_equal?(1.0, 1.1)).to be false
    end
  end

  describe '.within?' do
    it 'raises ArgumentError when neither abs nor rel is provided' do
      expect { described_class.within?(1.0, 2.0) }.to raise_error(ArgumentError)
    end

    context 'with only abs' do
      it 'passes when within absolute tolerance' do
        expect(described_class.within?(1.0, 1.05, abs: 0.1)).to be true
      end

      it 'fails when outside absolute tolerance' do
        expect(described_class.within?(1.0, 2.0, abs: 0.1)).to be false
      end
    end

    context 'with only rel' do
      it 'passes when within relative tolerance' do
        expect(described_class.within?(1_000.0, 1_001.0, rel: 1e-2)).to be true
      end

      it 'fails when outside relative tolerance' do
        expect(described_class.within?(1_000.0, 2_000.0, rel: 1e-2)).to be false
      end
    end

    context 'with both abs and rel' do
      it 'passes when absolute tolerance is met but relative is not' do
        # 0.001 and 0.002: abs diff = 0.001, rel diff = 0.5
        expect(described_class.within?(0.001, 0.002, abs: 0.01, rel: 1e-6)).to be true
      end

      it 'passes when relative tolerance is met but absolute is not' do
        # 1_000_000.0 and 1_000_001.0: abs diff = 1.0, rel diff = 1e-6
        expect(described_class.within?(1_000_000.0, 1_000_001.0, abs: 1e-9, rel: 1e-5)).to be true
      end

      it 'fails when neither tolerance is met' do
        expect(described_class.within?(1.0, 100.0, abs: 0.1, rel: 1e-6)).to be false
      end
    end

    context 'with arrays and hashes' do
      it 'compares arrays element-wise' do
        expect(described_class.within?([1.0, 2.0], [1.05, 2.05], abs: 0.1)).to be true
      end

      it 'compares hashes by value' do
        a = { x: 1_000.0 }
        b = { x: 1_001.0 }
        expect(described_class.within?(a, b, rel: 1e-2)).to be true
      end
    end

    context 'with edge cases' do
      it 'handles NaN' do
        expect(described_class.within?(Float::NAN, Float::NAN, abs: 1.0)).to be false
      end

      it 'handles Infinity' do
        expect(described_class.within?(Float::INFINITY, Float::INFINITY, abs: 1.0)).to be false
      end

      it 'handles zero' do
        expect(described_class.within?(0.0, 0.0, abs: 1e-9)).to be true
      end
    end
  end

  describe Philiprehberger::Approx::Comparator do
    describe '#equal?' do
      it 'uses default epsilon' do
        c = described_class.new
        expect(c.equal?(1.0, 1.0 + 1e-10)).to be true
        expect(c.equal?(1.0, 2.0)).to be false
      end

      it 'uses custom epsilon' do
        c = described_class.new(epsilon: 0.1)
        expect(c.equal?(1.0, 1.05)).to be true
        expect(c.equal?(1.0, 1.2)).to be false
      end

      it 'uses relative tolerance only' do
        c = described_class.new(epsilon: nil, relative: 1e-3)
        expect(c.equal?(1_000.0, 1_000.5)).to be true
        expect(c.equal?(1.0, 2.0)).to be false
      end

      it 'uses combined tolerances' do
        c = described_class.new(epsilon: 0.01, relative: 1e-3)
        # passes via relative
        expect(c.equal?(1_000.0, 1_000.5)).to be true
        # passes via absolute
        expect(c.equal?(0.001, 0.005)).to be true
      end

      it 'compares arrays' do
        c = described_class.new(epsilon: 0.1)
        expect(c.equal?([1.0, 2.0], [1.05, 2.05])).to be true
      end

      it 'compares hashes' do
        c = described_class.new(epsilon: 0.1)
        expect(c.equal?({ x: 1.0 }, { x: 1.05 })).to be true
      end
    end

    describe '#assert_near' do
      it 'does not raise for near values' do
        c = described_class.new(epsilon: 0.1)
        expect { c.assert_near(1.0, 1.05) }.not_to raise_error
      end

      it 'raises Error for distant values' do
        c = described_class.new
        expect { c.assert_near(1.0, 2.0) }.to raise_error(Philiprehberger::Approx::Error)
      end

      it 'includes values and tolerances in error message' do
        c = described_class.new(epsilon: 0.01, relative: 0.001)
        expect { c.assert_near(1.0, 100.0) }.to raise_error(/expected 1.0 to be near 100.0/)
      end
    end

    describe '#relative_equal?' do
      it 'uses relative tolerance from constructor' do
        c = described_class.new(relative: 1e-3)
        expect(c.relative_equal?(1_000.0, 1_000.5)).to be true
      end

      it 'returns false when outside tolerance' do
        c = described_class.new(relative: 1e-6)
        expect(c.relative_equal?(1.0, 2.0)).to be false
      end

      it 'falls back to epsilon when relative is nil' do
        c = described_class.new(epsilon: 0.5)
        expect(c.relative_equal?(1.0, 1.3)).to be true
      end
    end

    describe '#clamp' do
      it 'snaps near value to target' do
        c = described_class.new(epsilon: 0.1)
        expect(c.clamp(1.05, 1.0)).to eq(1.0)
      end

      it 'returns value unchanged when not near' do
        c = described_class.new(epsilon: 0.01)
        expect(c.clamp(1.5, 1.0)).to eq(1.5)
      end
    end

    describe '#zero?' do
      it 'detects approximately zero values' do
        c = described_class.new(epsilon: 0.01)
        expect(c.zero?(0.005)).to be true
      end

      it 'returns false for non-zero values' do
        c = described_class.new
        expect(c.zero?(1.0)).to be false
      end
    end

    describe '#between?' do
      it 'checks value within range' do
        c = described_class.new(epsilon: 0.1)
        expect(c.between?(5.0, 1.0, 10.0)).to be true
      end

      it 'allows epsilon slack on bounds' do
        c = described_class.new(epsilon: 0.1)
        expect(c.between?(10.05, 1.0, 10.0)).to be true
      end

      it 'returns false when outside range plus epsilon' do
        c = described_class.new(epsilon: 0.01)
        expect(c.between?(11.0, 1.0, 10.0)).to be false
      end
    end

    describe '#assert_within' do
      it 'does not raise when within tolerance' do
        c = described_class.new(epsilon: 0.1, relative: 1e-3)
        expect { c.assert_within(1.0, 1.05) }.not_to raise_error
      end

      it 'raises Error when outside tolerance' do
        c = described_class.new(epsilon: 0.001, relative: 1e-9)
        expect { c.assert_within(1.0, 2.0) }.to raise_error(Philiprehberger::Approx::Error)
      end
    end

    describe '#tolerance_range' do
      it 'returns bounds using configured epsilon' do
        c = described_class.new(epsilon: 0.1)
        expect(c.tolerance_range(5.0)).to eq([4.9, 5.1])
      end

      it 'uses default epsilon' do
        c = described_class.new
        min, max = c.tolerance_range(1.0)
        expect(min).to be_within(1e-15).of(1.0 - 1e-9)
        expect(max).to be_within(1e-15).of(1.0 + 1e-9)
      end

      it 'handles zero value' do
        c = described_class.new(epsilon: 0.5)
        expect(c.tolerance_range(0.0)).to eq([-0.5, 0.5])
      end

      it 'handles negative value' do
        c = described_class.new(epsilon: 0.1)
        expect(c.tolerance_range(-3.0)).to eq([-3.1, -2.9])
      end
    end

    describe 'attributes' do
      it 'exposes epsilon' do
        c = described_class.new(epsilon: 0.5)
        expect(c.epsilon).to eq(0.5)
      end

      it 'exposes relative' do
        c = described_class.new(relative: 0.01)
        expect(c.relative).to eq(0.01)
      end
    end
  end
end
