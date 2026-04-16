# frozen_string_literal: true

module Philiprehberger
  module Approx
    module RSpecMatchers
      # Matcher for approximate equality using epsilon
      #
      # When rel_tol is non-zero, the matcher passes if either the absolute
      # epsilon or the relative tolerance is met (Python math.isclose semantics).
      #
      # @example
      #   expect(1.0).to be_approx(1.0 + 1e-10)
      #   expect(1.0).to be_approx(1.05, epsilon: 0.1)
      #   expect(1e12).to be_approx(1e12 + 1e9, rel_tol: 0.01)
      def be_approx(expected, epsilon: Float::EPSILON, rel_tol: 0)
        BeApproxMatcher.new(expected, epsilon, rel_tol)
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
        def initialize(expected, epsilon, rel_tol = 0)
          @expected = expected
          @epsilon = epsilon
          @rel_tol = rel_tol
        end

        def matches?(actual)
          @actual = actual
          Approx.equal?(actual, @expected, epsilon: @epsilon, rel_tol: @rel_tol)
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
          parts = ["epsilon: #{@epsilon}"]
          parts << "rel_tol: #{@rel_tol}" if @rel_tol && !@rel_tol.zero?
          parts.join(', ')
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
