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

### Assert Near

```ruby
Philiprehberger::Approx.assert_near(1.0, 1.0 + 1e-10)
# => nil (no error)

Philiprehberger::Approx.assert_near(1.0, 2.0)
# => raises Philiprehberger::Approx::Error
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
| `Comparator.new(epsilon:, relative:)` | Reusable comparator with preset tolerances |
| `Comparator#equal?(a, b)` | Check equality using configured tolerances |
| `Comparator#assert_near(a, b)` | Raise `Error` if values are not approximately equal |
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
