# philiprehberger-approx

[![Tests](https://github.com/philiprehberger/rb-approx/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-approx/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-approx.svg)](https://rubygems.org/gems/philiprehberger-approx)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-approx)](https://github.com/philiprehberger/rb-approx/commits/main)

Epsilon-based approximate equality for floats, arrays, and hashes

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-approx"
```

Or install directly:

```bash
gem install philiprehberger-approx
```

## Usage

```ruby
require "philiprehberger/approx"

Philiprehberger::Approx.equal?(1.0, 1.0 + 1e-10)
# => true

Philiprehberger::Approx.equal?(1.0, 1.1)
# => false
```

### Custom Epsilon

```ruby
Philiprehberger::Approx.equal?(1.0, 1.05, epsilon: 0.1)
# => true
```

### Array and Hash Comparison

```ruby
Philiprehberger::Approx.equal?([1.0, 2.0], [1.0 + 1e-10, 2.0])
# => true

Philiprehberger::Approx.equal?({ x: 1.0 }, { x: 1.0 + 1e-10 })
# => true
```

### Relative Tolerance

```ruby
Philiprehberger::Approx.relative_equal?(1_000_000.0, 1_000_001.0, tolerance: 1e-5)
# => true

Philiprehberger::Approx.relative_equal?(1.0, 2.0, tolerance: 1e-6)
# => false
```

Supports arrays and hashes recursively, just like `equal?`. Falls back to absolute comparison when both values are zero.

### Combined Tolerance

```ruby
Philiprehberger::Approx.within?(1_000_000.0, 1_000_001.0, abs: 1e-9, rel: 1e-5)
# => true (passes via relative tolerance)

Philiprehberger::Approx.within?(0.001, 0.002, abs: 0.01, rel: 1e-9)
# => true (passes via absolute tolerance)
```

Passes if either the absolute or relative tolerance is met. At least one of `abs:` or `rel:` must be provided.

### Clamp (Snap Near-Values)

```ruby
Philiprehberger::Approx.clamp(1.0 + 1e-10, 1.0)
# => 1.0 (snapped to target)

Philiprehberger::Approx.clamp(1.1, 1.0)
# => 1.1 (returned unchanged)

Philiprehberger::Approx.clamp(1.05, 1.0, epsilon: 0.1)
# => 1.0 (snapped with custom epsilon)
```

Returns the target if the value is approximately equal, otherwise returns the value unchanged. Useful for snapping near-values to an exact canonical value.

### Reusable Comparator

```ruby
comparator = Philiprehberger::Approx::Comparator.new(epsilon: 0.01, relative: 1e-3)

comparator.equal?(1_000.0, 1_000.5)
# => true

comparator.assert_near(1.0, 100.0)
# => raises Philiprehberger::Approx::Error
```

### Zero Check

```ruby
Philiprehberger::Approx.zero?(1e-12)
# => true

Philiprehberger::Approx.zero?(0.05, epsilon: 0.1)
# => true
```

### Range Check

```ruby
Philiprehberger::Approx.between?(5.0, 1.0, 10.0)
# => true

Philiprehberger::Approx.between?(10.0 + 1e-10, 1.0, 10.0)
# => true (within epsilon of upper bound)
```

### Tolerance Range

```ruby
Philiprehberger::Approx.tolerance_range(5.0, epsilon: 0.1)
# => [4.9, 5.1]

Philiprehberger::Approx.tolerance_range(0.0, epsilon: 0.5)
# => [-0.5, 0.5]
```

Returns `[min, max]` bounds around a value for a given epsilon. Also available on the `Comparator` using the configured epsilon.

### Sign Equality

```ruby
Philiprehberger::Approx.sign_equal?(5.0, 7.0)
# => true (both positive)

Philiprehberger::Approx.sign_equal?(2.0, -3.0)
# => false (opposite signs)

Philiprehberger::Approx.sign_equal?(1e-12, -1e-12)
# => true (both near zero)
```

Values with `|x| <= epsilon` are treated as zero, so two near-zero values are considered to share a sign regardless of their raw polarity.

### Assert Within

```ruby
Philiprehberger::Approx.assert_within(1_000_000.0, 1_000_001.0, rel: 1e-5)
# => nil (passes via relative tolerance)

Philiprehberger::Approx.assert_within(1.0, 2.0, abs: 0.01)
# => raises Philiprehberger::Approx::Error
```

### Assert Near

```ruby
Philiprehberger::Approx.assert_near(1.0, 1.0 + 1e-10)
# => nil (no error)

Philiprehberger::Approx.assert_near(1.0, 2.0)
# => raises Philiprehberger::Approx::Error
```

### Percentage Tolerance

```ruby
Philiprehberger::Approx.percent_equal?(100.0, 105.0, percent: 10)
# => true (5% difference is within 10% tolerance)

Philiprehberger::Approx.percent_equal?(100.0, 115.0, percent: 10)
# => false (15% difference exceeds 10% tolerance)
```

Supports arrays and hashes recursively. Returns true when both values are zero.

### Diff Diagnostics

```ruby
Philiprehberger::Approx.diff(1.0, 1.5, epsilon: 1.0)
# => { match: true, actual_diff: 0.5, allowed: 1.0, ratio: 0.5 }

Philiprehberger::Approx.diff(1.0, 3.0, epsilon: 1.0)
# => { match: false, actual_diff: 2.0, allowed: 1.0, ratio: 2.0 }
```

Returns a diagnostic hash showing the actual difference, the allowed tolerance, and the ratio between them.

### RSpec Integration

```ruby
require 'philiprehberger/approx'

RSpec.configure do |config|
  config.include Philiprehberger::Approx::RSpecMatchers
end

RSpec.describe 'calculations' do
  it 'is approximately equal' do
    expect(1.0).to be_approx(1.0 + 1e-16)
    expect(1.0).to be_approx(1.05, epsilon: 0.1)
  end

  it 'is within tolerance' do
    expect(1.0).to be_approx_within(1.005, abs: 0.01)
    expect(1_000_000.0).to be_approx_within(1_000_001.0, rel: 1e-5)
    expect(100.0).to be_approx_within(105.0, percent: 10)
  end
end
```

## API

| Method | Description |
|--------|-------------|
| `.equal?(a, b, epsilon: 1e-9)` | Check approximate equality within epsilon |
| `.near?(a, b, epsilon: 1e-9)` | Alias for `.equal?` |
| `.relative_equal?(a, b, tolerance: 1e-6)` | Check relative tolerance: `\|a - b\| / max(\|a\|, \|b\|) <= tolerance` |
| `.within?(a, b, abs: nil, rel: nil)` | Combined mode: passes if either absolute or relative tolerance is met |
| `.clamp(value, target, epsilon: 1e-9)` | Return target if approximately equal, otherwise return value unchanged |
| `.assert_near(a, b, epsilon: 1e-9)` | Raise `Error` if values differ by more than epsilon |
| `.assert_within(a, b, abs: nil, rel: nil)` | Raise `Error` if values fail both tolerance checks |
| `.zero?(value, epsilon: 1e-9)` | Check if a numeric value is approximately zero |
| `.percent_equal?(a, b, percent:)` | Check approximate equality within a percentage tolerance |
| `.diff(a, b, epsilon: Float::EPSILON)` | Return diagnostic hash with match status, actual diff, allowed diff, and ratio |
| `.between?(value, min, max, epsilon: 1e-9)` | Check if value lies in `[min, max]` with epsilon slack |
| `.tolerance_range(value, epsilon: 1e-9)` | Return `[min, max]` bounds around a value for a given epsilon |
| `.sign_equal?(a, b, epsilon: 1e-9)` | Check if two values share the same sign, treating near-zero values as zero |
| `RSpecMatchers#be_approx(expected, epsilon:)` | RSpec matcher for approximate equality |
| `RSpecMatchers#be_approx_within(expected, abs:, rel:, percent:)` | RSpec matcher with abs, rel, or percent tolerance |
| `Comparator.new(epsilon:, relative:)` | Reusable comparator with preset tolerances |
| `Comparator#equal?(a, b)` | Check equality using configured tolerances |
| `Comparator#near?(a, b)` | Alias for `Comparator#equal?` |
| `Comparator#within?(a, b)` | Check using combined absolute + relative configured tolerances |
| `Comparator#assert_near(a, b)` | Raise `Error` if values are not approximately equal |
| `Comparator#relative_equal?(a, b)` | Check relative tolerance using configured tolerances |
| `Comparator#clamp(value, target)` | Snap value to target using configured epsilon |
| `Comparator#zero?(value)` | Check if value is approximately zero using configured epsilon |
| `Comparator#between?(value, min, max)` | Check if value lies in range using configured epsilon |
| `Comparator#tolerance_range(value)` | Return `[min, max]` bounds using configured epsilon |
| `Comparator#assert_within(a, b)` | Raise `Error` if values fail configured tolerance checks |
| `Error` | Error class raised by `.assert_near` (inherits `StandardError`) |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-approx)

🐛 [Report issues](https://github.com/philiprehberger/rb-approx/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-approx/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
