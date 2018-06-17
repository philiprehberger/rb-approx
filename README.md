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
| `.assert_near(a, b, epsilon: 1e-9)` | Raise `Error` if values differ by more than epsilon |
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
