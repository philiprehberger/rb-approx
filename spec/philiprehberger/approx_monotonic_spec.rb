# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Approx do
  describe '.monotonic?' do
    context 'with edge-case sizes' do
      it 'returns true for an empty array' do
        expect(described_class.monotonic?([])).to be true
      end

      it 'returns true for a single-element array' do
        expect(described_class.monotonic?([42.0])).to be true
      end
    end

    context 'with :increasing' do
      it 'returns true for a strictly increasing sequence' do
        expect(described_class.monotonic?([1.0, 2.0, 3.0, 4.0], direction: :increasing)).to be true
      end

      it 'returns false when adjacent elements are approximately equal' do
        expect(
          described_class.monotonic?([1.0, 1.0 + 1e-12, 2.0], direction: :increasing)
        ).to be false
      end

      it 'returns false for a non-increasing pair' do
        expect(described_class.monotonic?([1.0, 2.0, 2.0, 3.0], direction: :increasing)).to be false
      end
    end

    context 'with :decreasing' do
      it 'returns true for a strictly decreasing sequence' do
        expect(described_class.monotonic?([5.0, 3.0, 1.0], direction: :decreasing)).to be true
      end

      it 'returns false when adjacent elements are approximately equal' do
        expect(
          described_class.monotonic?([3.0, 3.0 - 1e-12, 2.0], direction: :decreasing)
        ).to be false
      end
    end

    context 'with :non_decreasing' do
      it 'returns true when ties are present' do
        expect(
          described_class.monotonic?([1.0, 1.0, 2.0, 2.0, 3.0], direction: :non_decreasing)
        ).to be true
      end

      it 'returns true when neighbors are approximately equal within tolerance' do
        expect(
          described_class.monotonic?(
            [1.0, 1.0 + 1e-12, 2.0],
            direction: :non_decreasing
          )
        ).to be true
      end

      it 'returns false for a drop larger than epsilon' do
        expect(
          described_class.monotonic?([1.0, 0.5, 1.0], direction: :non_decreasing)
        ).to be false
      end
    end

    context 'with :non_increasing' do
      it 'returns true when ties are present' do
        expect(
          described_class.monotonic?([3.0, 3.0, 2.0, 2.0, 1.0], direction: :non_increasing)
        ).to be true
      end

      it 'returns true when neighbors are approximately equal within tolerance' do
        expect(
          described_class.monotonic?(
            [3.0, 3.0 - 1e-12, 2.0],
            direction: :non_increasing
          )
        ).to be true
      end
    end

    context 'with tolerance-relaxed near-ties' do
      it 'accepts a tiny backwards step under non_decreasing within epsilon' do
        expect(
          described_class.monotonic?(
            [1.0, 1.0 - 1e-10, 2.0],
            direction: :non_decreasing,
            epsilon: 1e-9
          )
        ).to be true
      end

      it 'rejects strict-increasing when the tie is inside the relaxed epsilon' do
        expect(
          described_class.monotonic?(
            [1.0, 1.0 + 1e-4, 2.0],
            direction: :increasing,
            epsilon: 1e-3
          )
        ).to be false
      end
    end

    context 'with an unknown direction' do
      it 'raises ArgumentError' do
        expect { described_class.monotonic?([1, 2, 3], direction: :sideways) }
          .to raise_error(ArgumentError, /unknown direction/)
      end
    end

    context 'with a mixed sequence' do
      it 'returns false for any direction' do
        values = [1.0, 3.0, 2.0, 4.0]
        expect(described_class.monotonic?(values, direction: :increasing)).to be false
        expect(described_class.monotonic?(values, direction: :decreasing)).to be false
        expect(described_class.monotonic?(values, direction: :non_decreasing)).to be false
        expect(described_class.monotonic?(values, direction: :non_increasing)).to be false
      end
    end
  end
end
