# frozen_string_literal: true

require_relative 'approx/version'
require_relative 'approx/comparator'
require_relative 'approx/rspec_matchers'

module Philiprehberger
  module Approx
    class Error < StandardError; end

    # Check if two values are approximately equal within epsilon
    #
    # When rel_tol is non-zero, values match if either tolerance passes,
    # matching Python's math.isclose semantics:
    # |a - b| <= max(rel_tol * max(|a|, |b|), epsilon)
    #
    # @param a [Numeric, Array, Hash] first value
    # @param b [Numeric, Array, Hash] second value
    # @param epsilon [Float] maximum allowed absolute difference
    # @param rel_tol [Float] relative tolerance (default 0 — disabled)
    # @return [Boolean] true if values are approximately equal
    def self.equal?(a, b, epsilon: 1e-9, rel_tol: 0)
      compare_recursive(a, b, epsilon, rel_tol)
    end

    # Alias for equal? with explicit epsilon
    #
    # @param a [Numeric, Array, Hash] first value
    # @param b [Numeric, Array, Hash] second value
    # @param epsilon [Float] maximum allowed absolute difference
    # @param rel_tol [Float] relative tolerance (default 0 — disabled)
    # @return [Boolean] true if values are near each other
    def self.near?(a, b, epsilon: 1e-9, rel_tol: 0)
      equal?(a, b, epsilon: epsilon, rel_tol: rel_tol)
    end

    # Check if every element of an enumerable is approximately equal to the first
    #
    # Accepts any Enumerable and iterates via .to_a. Empty and single-element
    # collections return true. Reuses the same tolerance semantics as .equal?,
    # so either absolute epsilon or relative tolerance (or both) may be supplied.
    #
    # @param values [Enumerable] collection of values to compare
    # @param epsilon [Float] maximum allowed absolute difference (defaults to .equal?'s default)
    # @param rel_tol [Float] relative tolerance (defaults to .equal?'s default)
    # @return [Boolean] true if every element is approximately equal to the first
    def self.all_equal?(values, epsilon: nil, rel_tol: nil)
      arr = values.to_a
      return true if arr.length < 2

      opts = {}
      opts[:epsilon] = epsilon unless epsilon.nil?
      opts[:rel_tol] = rel_tol unless rel_tol.nil?

      first = arr.first
      arr.drop(1).all? { |v| equal?(first, v, **opts) }
    end

    # Check if a sequence is approximately monotonic under the tolerance model of .equal?
    #
    # Pairwise compares adjacent elements using the same absolute/relative tolerance
    # helpers as .equal?. For strict directions (:increasing, :decreasing) each pair
    # must satisfy the strict inequality AND must not be approximately equal within
    # the configured tolerance. For non-strict directions (:non_decreasing,
    # :non_increasing) each pair must satisfy the non-strict inequality OR be
    # approximately equal within the configured tolerance. Empty and single-element
    # sequences return true.
    #
    # @param values [Enumerable] collection of values to inspect
    # @param direction [Symbol] one of :increasing, :decreasing, :non_decreasing, :non_increasing
    # @param epsilon [Float] maximum allowed absolute difference (defaults to .equal?'s default)
    # @param rel_tol [Float] relative tolerance (default 0 — disabled)
    # @return [Boolean] true if the sequence is approximately monotonic in the requested direction
    # @raise [ArgumentError] if direction is not one of the four accepted symbols
    def self.monotonic?(values, direction: :increasing, epsilon: nil, rel_tol: 0.0)
      unless %i[increasing decreasing non_decreasing non_increasing].include?(direction)
        raise ArgumentError, "unknown direction: #{direction.inspect}"
      end

      arr = values.to_a
      return true if arr.length < 2

      opts = { rel_tol: rel_tol }
      opts[:epsilon] = epsilon unless epsilon.nil?

      arr.each_cons(2).all? do |a, b|
        near = equal?(a, b, **opts)
        case direction
        when :increasing     then a < b && !near
        when :decreasing     then a > b && !near
        when :non_decreasing then a <= b || near
        when :non_increasing then a >= b || near
        end
      end
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
    # @param epsilon [Float] maximum allowed absolute difference
    # @param rel_tol [Float] relative tolerance (default 0 — disabled)
    # @return [Numeric] target if approximately equal, otherwise value
    def self.clamp(value, target, epsilon: 1e-9, rel_tol: 0)
      equal?(value, target, epsilon: epsilon, rel_tol: rel_tol) ? target : value
    end

    # Assert that two values are approximately equal, raising on mismatch
    #
    # @param a [Numeric, Array, Hash] first value
    # @param b [Numeric, Array, Hash] second value
    # @param epsilon [Float] maximum allowed absolute difference
    # @param rel_tol [Float] relative tolerance (default 0 — disabled)
    # @raise [Error] if values differ by more than the allowed tolerance
    def self.assert_near(a, b, epsilon: 1e-9, rel_tol: 0)
      return if equal?(a, b, epsilon: epsilon, rel_tol: rel_tol)

      raise Error, "expected #{a.inspect} to be near #{b.inspect} (epsilon: #{epsilon}, rel_tol: #{rel_tol})"
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

    # Return the tolerance bounds [min, max] around a value for a given epsilon
    #
    # @param value [Numeric] center value
    # @param epsilon [Float] tolerance radius
    # @return [Array<Numeric>] two-element array [value - epsilon, value + epsilon]
    def self.tolerance_range(value, epsilon: 1e-9)
      [value - epsilon, value + epsilon]
    end

    # Check if two numeric values share the same sign
    #
    # Values with |x| <= epsilon are treated as zero, so two near-zero values
    # are considered to share a sign regardless of their raw polarity.
    #
    # @param a [Numeric] first value
    # @param b [Numeric] second value
    # @param epsilon [Float] threshold below which a value is treated as zero
    # @return [Boolean] true if both values share the same sign (or both are near zero)
    def self.sign_equal?(a, b, epsilon: 1e-9)
      a_zero = a.abs <= epsilon
      b_zero = b.abs <= epsilon
      return true if a_zero && b_zero
      return false if a_zero || b_zero

      (a.positive? && b.positive?) || (a.negative? && b.negative?)
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

    # Find the element pair with the largest absolute difference across two arrays or hashes
    #
    # For arrays, iterates element-by-element and returns the index and values of
    # the pair with the greatest absolute difference. For hashes, iterates over
    # shared keys and uses :key instead of :index. Returns nil if both collections
    # are empty. Raises Approx::Error for mismatched types or non-collection inputs.
    #
    # @param a [Array, Hash] first collection
    # @param b [Array, Hash] second collection
    # @param epsilon [Float] tolerance used to set :match on the returned hash
    # @return [Hash, nil] hash with :index/:key, :a, :b, :diff, :match, :epsilon or nil
    # @raise [Error] if inputs are not both arrays or both hashes
    def self.max_diff(a, b, epsilon: 1e-10)
      unless (a.is_a?(Array) && b.is_a?(Array)) || (a.is_a?(Hash) && b.is_a?(Hash))
        raise Error, 'both arguments must be arrays or both must be hashes'
      end

      if a.is_a?(Array)
        flat_a = a.flatten
        flat_b = b.flatten
        return nil if flat_a.empty? && flat_b.empty?

        best = nil
        flat_a.each_with_index do |val_a, i|
          val_b = flat_b[i]
          d = (val_a - val_b).abs
          best = { index: i, a: val_a, b: val_b, diff: d } if best.nil? || d > best[:diff]
        end
        best.merge(match: best[:diff] <= epsilon, epsilon: epsilon)
      else
        shared_keys = a.keys & b.keys
        return nil if shared_keys.empty?

        best = nil
        shared_keys.each do |k|
          val_a = a[k]
          val_b = b[k]
          d = (val_a - val_b).abs
          best = { key: k, a: val_a, b: val_b, diff: d } if best.nil? || d > best[:diff]
        end
        best.merge(match: best[:diff] <= epsilon, epsilon: epsilon)
      end
    end

    # Three-way comparison with tolerance — like Ruby's spaceship operator,
    # except values within tolerance return 0.
    #
    # Returns 0 when a and b are approximately equal (delegates to .equal?),
    # otherwise returns -1 if a < b, 1 if a > b. NaN/incomparable values
    # return nil so callers can detect the case the same way as Ruby's <=>.
    #
    # @param a [Numeric] first value
    # @param b [Numeric] second value
    # @param epsilon [Float] maximum allowed absolute difference
    # @param rel_tol [Float] relative tolerance (default 0 — disabled)
    # @return [Integer, nil] -1, 0, 1, or nil for incomparable values
    def self.compare(a, b, epsilon: 1e-9, rel_tol: 0)
      return 0 if equal?(a, b, epsilon: epsilon, rel_tol: rel_tol)

      a <=> b
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

      def compare_recursive(a, b, epsilon, rel_tol = 0)
        case [a, b]
        in [Numeric, Numeric]
          diff = (a - b).abs
          return true if diff <= epsilon
          return false if rel_tol.nil? || rel_tol.zero?
          return false if a.respond_to?(:nan?) && a.nan?
          return false if b.respond_to?(:nan?) && b.nan?
          return false if a.respond_to?(:infinite?) && a.infinite?
          return false if b.respond_to?(:infinite?) && b.infinite?

          diff <= rel_tol * [a.abs, b.abs].max
        in [Array, Array]
          return false unless a.length == b.length

          a.zip(b).all? { |x, y| compare_recursive(x, y, epsilon, rel_tol) }
        in [Hash, Hash]
          return false unless a.keys.sort == b.keys.sort

          a.all? { |k, v| compare_recursive(v, b[k], epsilon, rel_tol) }
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
