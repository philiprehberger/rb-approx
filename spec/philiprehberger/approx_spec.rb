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
  end

  describe '.near?' do
    it 'behaves like equal?' do
      expect(described_class.near?(1.0, 1.0 + 1e-10)).to be true
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
  end
end
