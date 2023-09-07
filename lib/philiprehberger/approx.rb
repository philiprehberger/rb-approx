# frozen_string_literal: true

require_relative 'approx/version'
require_relative 'approx/comparator'
require_relative 'approx/rspec_matchers'

module Philiprehberger
  module Approx
    class Error < StandardError; end

    # Check if two values are approximately equal within epsilon
    #
    # @param a [Numeric, Array, Hash] first value
    # @param b [Numeric, Array, Hash] second value
    # @param epsilon [Float] maximum allowed difference
    # @return [Boolean] true if values are approximately equal
    def self.equal?(a, b, epsilon: 1e-9)
      compare(a, b, epsilon)
    end

    # Alias for equal? with explicit epsilon
    #
    # @param a [Numeric, Array, Hash] first value
    # @param b [Numeric, Array, Hash] second value
    # @param epsilon [Float] maximum allowed difference
    # @return [Boolean] true if values are near each other
    def self.near?(a, b, epsilon: 1e-9)
      equal?(a, b, epsilon: epsilon)
    end

    # Check if two values are approximately equal using relative tolerance
    #
    # Relative tolerance: |a - b| / max(|a|, |b|) <= tolerance
    # Falls back to absolute comparison when both values are zero.
    #
    # @param a [Numeric, Array, Hash] first value
    # @param b [Numeric, Array, Hash] second value
    # @param tolerance [Float] maximum allowed relative difference
    # @return [Boolean] true if values are relatively near each other
    def self.relative_equal?(a, b, tolerance: 1e-6)
      compare_relative(a, b, tolerance)
    end

    # Check if two values are approximately equal using combined tolerance
    #
    # Passes if either absolute or relative tolerance is met.
    # At least one of abs: or rel: must be provided.
    #
    # @param a [Numeric, Array, Hash] first value
    # @param b [Numeric, Array, Hash] second value
    # @param abs [Float, nil] absolute tolerance
    # @param rel [Float, nil] relative tolerance
    # @return [Boolean] true if values pass either tolerance check
    def self.within?(a, b, abs: nil, rel: nil)
      raise ArgumentError, 'at least one of abs: or rel: must be provided' if abs.nil? && rel.nil?

      compare_within(a, b, abs, rel)
    end

    # Snap a value to target if approximately equal, otherwise return unchanged
    #
    # Returns target when value is within epsilon of target. Useful for
    # snapping near-values to an exact canonical value.
    #
    # @param value [Numeric] the value to potentially snap
    # @param target [Numeric] the target to snap to
    # @param epsilon [Float] maximum allowed difference
    # @return [Numeric] target if approximately equal, otherwise value
    def self.clamp(value, target, epsilon: 1e-9)
      equal?(value, target, epsilon: epsilon) ? target : value
    end

    # Assert that two values are approximately equal, raising on mismatch
    #
    # @param a [Numeric, Array, Hash] first value
    # @param b [Numeric, Array, Hash] second value
    # @param epsilon [Float] maximum allowed difference
    # @raise [Error] if values differ by more than epsilon
    def self.assert_near(a, b, epsilon: 1e-9)
      return if equal?(a, b, epsilon: epsilon)

      raise Error, "expected #{a.inspect} to be near #{b.inspect} (epsilon: #{epsilon})"
    end

    # Check if a numeric value is approximately zero
    #
    # @param value [Numeric] value to test
    # @param epsilon [Float] maximum allowed difference from zero
    # @return [Boolean] true if |value| <= epsilon
    def self.zero?(value, epsilon: 1e-9)
      value.abs <= epsilon
    end

    # Check if a numeric value lies within [min, max] with epsilon slack on both ends
    #
    # @param value [Numeric] value to test
    # @param min [Numeric] inclusive lower bound
    # @param max [Numeric] inclusive upper bound
    # @param epsilon [Float] tolerance applied to each bound
    # @return [Boolean] true if min - epsilon <= value <= max + epsilon
    def self.between?(value, min, max, epsilon: 1e-9)
      value.between?(min - epsilon, max + epsilon)
    end

    # Assert that two values pass within?, raising on mismatch
    #
    # At least one of abs: or rel: must be provided.
    #
    # @param a [Numeric, Array, Hash] first value
    # @param b [Numeric, Array, Hash] second value
    # @param abs [Float, nil] absolute tolerance
    # @param rel [Float, nil] relative tolerance
    # @raise [Error] if values fail both tolerance checks
    def self.assert_within(a, b, abs: nil, rel: nil)
      return if within?(a, b, abs: abs, rel: rel)

      raise Error, "expected #{a.inspect} to be within #{b.inspect} (abs: #{abs}, rel: #{rel})"
    end

    # Check if two values are approximately equal within a percentage tolerance
    #
    # @param a [Numeric, Array, Hash] first value
    # @param b [Numeric, Array, Hash] second value
    # @param percent [Float] maximum allowed percentage difference
    # @return [Boolean] true if values are within the percentage tolerance
    def self.percent_equal?(a, b, percent:)
      compare_percent(a, b, percent)
    end

    # Return a diagnostic hash showing why values do or do not match
    #
    # @param a [Numeric] first value
    # @param b [Numeric] second value
    # @param epsilon [Float] maximum allowed difference
    # @return [Hash] diagnostic hash with :match, :actual_diff, :allowed, :ratio
    def self.diff(a, b, epsilon: Float::EPSILON)
      actual_diff = (a - b).abs.to_f
      allowed = epsilon.to_f
      ratio = allowed.zero? ? Float::INFINITY : actual_diff / allowed

      {
        match: actual_diff <= allowed,
        actual_diff: actual_diff,
        allowed: allowed,
        ratio: ratio
      }
    end

    class << self
      private

      def compare(a, b, epsilon)
        case [a, b]
        in [Numeric, Numeric]
          (a - b).abs <= epsilon
        in [Array, Array]
          return false unless a.length == b.length

          a.zip(b).all? { |x, y| compare(x, y, epsilon) }
        in [Hash, Hash]
          return false unless a.keys.sort == b.keys.sort

          a.all? { |k, v| compare(v, b[k], epsilon) }
        else
          a == b
        end
      end

      def compare_relative(a, b, tolerance)
        case [a, b]
        in [Numeric, Numeric]
          relative_near?(a, b, tolerance)
        in [Array, Array]
          return false unless a.length == b.length

          a.zip(b).all? { |x, y| compare_relative(x, y, tolerance) }
        in [Hash, Hash]
          return false unless a.keys.sort == b.keys.sort

          a.all? { |k, v| compare_relative(v, b[k], tolerance) }
        else
          a == b
        end
      end

      def compare_within(a, b, abs, rel)
        case [a, b]
        in [Numeric, Numeric]
          result = false
          result ||= (a - b).abs <= abs if abs
          result ||= relative_near?(a, b, rel) if rel
          result
        in [Array, Array]
          return false unless a.length == b.length

          a.zip(b).all? { |x, y| compare_within(x, y, abs, rel) }
        in [Hash, Hash]
          return false unless a.keys.sort == b.keys.sort

          a.all? { |k, v| compare_within(v, b[k], abs, rel) }
        else
          a == b
        end
      end

      def compare_percent(a, b, percent)
        case [a, b]
        in [Numeric, Numeric]
          percent_near?(a, b, percent)
        in [Array, Array]
          return false unless a.length == b.length

          a.zip(b).all? { |x, y| compare_percent(x, y, percent) }
        in [Hash, Hash]
          return false unless a.keys.sort == b.keys.sort

          a.all? { |k, v| compare_percent(v, b[k], percent) }
        else
          a == b
        end
      end

      def percent_near?(a, b, percent)
        return true if a.zero? && b.zero?

        (a - b).abs <= (percent / 100.0) * [a.abs, b.abs].max
      end

      def relative_near?(a, b, tolerance)
        return false if a.respond_to?(:nan?) && a.nan?
        return false if b.respond_to?(:nan?) && b.nan?
        return false if a.respond_to?(:infinite?) && a.infinite?
        return false if b.respond_to?(:infinite?) && b.infinite?

        max_abs = [a.abs, b.abs].max
        if max_abs.zero?
          (a - b).abs.zero?
        else
          (a - b).abs / max_abs <= tolerance
        end
      end
    end
  end
end
