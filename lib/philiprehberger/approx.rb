# frozen_string_literal: true

require_relative 'approx/version'

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
    end
  end
end
