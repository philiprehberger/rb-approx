# frozen_string_literal: true

module Philiprehberger
  module Approx
    class Comparator
      attr_reader :epsilon, :relative

      # Create a reusable comparator with preset tolerances
      #
      # @param epsilon [Float, nil] absolute tolerance
      # @param relative [Float, nil] relative tolerance
      def initialize(epsilon: 1e-9, relative: nil)
        @epsilon = epsilon
        @relative = relative
      end

      # Check if two values are approximately equal using configured tolerances
      #
      # @param a [Numeric, Array, Hash] first value
      # @param b [Numeric, Array, Hash] second value
      # @return [Boolean]
      def equal?(a, b)
        if @relative && @epsilon
          Approx.within?(a, b, abs: @epsilon, rel: @relative)
        elsif @relative
          Approx.relative_equal?(a, b, tolerance: @relative)
        else
          Approx.equal?(a, b, epsilon: @epsilon)
        end
      end

      # Alias for #equal? matching the module-level near? naming
      #
      # @param a [Numeric, Array, Hash] first value
      # @param b [Numeric, Array, Hash] second value
      # @return [Boolean]
      def near?(a, b)
        equal?(a, b)
      end

      # Check using combined absolute + relative tolerance from the configured comparator
      #
      # @param a [Numeric, Array, Hash] first value
      # @param b [Numeric, Array, Hash] second value
      # @return [Boolean]
      def within?(a, b)
        Approx.within?(a, b, abs: @epsilon, rel: @relative)
      end

      # Assert that two values are approximately equal, raising on mismatch
      #
      # @param a [Numeric, Array, Hash] first value
      # @param b [Numeric, Array, Hash] second value
      # @raise [Error] if values are not approximately equal
      def assert_near(a, b)
        return if equal?(a, b)

        raise Error, "expected #{a.inspect} to be near #{b.inspect} (epsilon: #{@epsilon}, relative: #{@relative})"
      end

      # Check if two values are approximately equal using relative tolerance
      #
      # @param a [Numeric, Array, Hash] first value
      # @param b [Numeric, Array, Hash] second value
      # @return [Boolean]
      def relative_equal?(a, b)
        Approx.relative_equal?(a, b, tolerance: @relative || @epsilon)
      end

      # Snap a value to target if approximately equal, otherwise return unchanged
      #
      # @param value [Numeric] the value to potentially snap
      # @param target [Numeric] the target to snap to
      # @return [Numeric] target if approximately equal, otherwise value
      def clamp(value, target)
        Approx.clamp(value, target, epsilon: @epsilon)
      end

      # Check if a numeric value is approximately zero
      #
      # @param value [Numeric] value to test
      # @return [Boolean]
      def zero?(value)
        Approx.zero?(value, epsilon: @epsilon)
      end

      # Check if a numeric value lies within [min, max] with epsilon slack
      #
      # @param value [Numeric] value to test
      # @param min [Numeric] inclusive lower bound
      # @param max [Numeric] inclusive upper bound
      # @return [Boolean]
      def between?(value, min, max)
        Approx.between?(value, min, max, epsilon: @epsilon)
      end

      # Return the tolerance bounds [min, max] around a value using configured epsilon
      #
      # @param value [Numeric] center value
      # @return [Array<Numeric>] two-element array [value - epsilon, value + epsilon]
      def tolerance_range(value)
        Approx.tolerance_range(value, epsilon: @epsilon)
      end

      # Assert that two values pass within?, raising on mismatch
      #
      # @param a [Numeric, Array, Hash] first value
      # @param b [Numeric, Array, Hash] second value
      # @raise [Error] if values fail both tolerance checks
      def assert_within(a, b)
        Approx.assert_within(a, b, abs: @epsilon, rel: @relative)
      end
    end
  end
end
