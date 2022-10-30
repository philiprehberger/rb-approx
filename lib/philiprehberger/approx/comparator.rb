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
    end
  end
end
