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
end
