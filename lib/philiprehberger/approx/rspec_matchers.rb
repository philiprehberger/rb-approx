# frozen_string_literal: true

module Philiprehberger
  module Approx
    module RSpecMatchers
      # Matcher for approximate equality using epsilon
      #
      # @example
      #   expect(1.0).to be_approx(1.0 + 1e-10)
      #   expect(1.0).to be_approx(1.05, epsilon: 0.1)
      def be_approx(expected, epsilon: Float::EPSILON)
        BeApproxMatcher.new(expected, epsilon)
      end

      # Matcher for approximate equality using abs, rel, or percent tolerance
      #
      # @example
      #   expect(1.0).to be_approx_within(1.001, abs: 0.01)
      #   expect(1_000_000.0).to be_approx_within(1_000_001.0, rel: 1e-5)
      #   expect(100.0).to be_approx_within(105.0, percent: 10)
      def be_approx_within(expected, abs: nil, rel: nil, percent: nil)
        BeApproxWithinMatcher.new(expected, abs, rel, percent)
      end

      # @api private
      class BeApproxMatcher
        def initialize(expected, epsilon)
          @expected = expected
          @epsilon = epsilon
        end

        def matches?(actual)
          @actual = actual
          Approx.equal?(actual, @expected, epsilon: @epsilon)
        end

        def description
          "be approximately equal to #{@expected.inspect} (epsilon: #{@epsilon})"
        end

        def failure_message
          "expected #{@actual.inspect} to be approximately equal to #{@expected.inspect} (epsilon: #{@epsilon})"
        end

        def failure_message_when_negated
          "expected #{@actual.inspect} not to be approximately equal to #{@expected.inspect} (epsilon: #{@epsilon})"
        end
      end

      # @api private
      class BeApproxWithinMatcher
        def initialize(expected, abs, rel, percent)
          @expected = expected
          @abs = abs
          @rel = rel
          @percent = percent
        end

        def matches?(actual)
          @actual = actual

          if @percent
            Approx.percent_equal?(actual, @expected, percent: @percent)
          else
            Approx.within?(actual, @expected, abs: @abs, rel: @rel)
          end
        end

        def description
          "be approximately equal to #{@expected.inspect} (#{tolerance_description})"
        end

        def failure_message
          "expected #{@actual.inspect} to be approximately equal to #{@expected.inspect} (#{tolerance_description})"
        end

        def failure_message_when_negated
          "expected #{@actual.inspect} not to be approximately equal to #{@expected.inspect} (#{tolerance_description})"
        end

        private

        def tolerance_description
          parts = []
          parts << "abs: #{@abs}" if @abs
          parts << "rel: #{@rel}" if @rel
          parts << "percent: #{@percent}" if @percent
          parts.join(', ')
        end
      end
    end
  end
end
