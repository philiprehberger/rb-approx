# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.9.0] - 2026-04-16

### Added
- `rel_tol:` option on comparator and RSpec matchers for relative-tolerance approximate equality (combines with absolute `epsilon:` the same way as Python's `math.isclose`)

## [0.8.0] - 2026-04-15

### Added
- `Approx.tolerance_range(value, epsilon:)` returning `[min, max]` bounds around a value for a given epsilon
- `Comparator#tolerance_range(value)` using the configured epsilon

## [0.7.0] - 2026-04-15

### Added
- `Approx.sign_equal?(a, b, epsilon:)` to check whether two values share the same sign, treating near-zero values as zero

## [0.6.0] - 2026-04-14

### Added
- `Approx.percent_equal?(a, b, percent:)` for percentage-based tolerance comparison
- `Approx.diff(a, b, epsilon:)` returning diagnostic hash with match status, actual diff, allowed diff, and ratio
- `Approx::RSpecMatchers` module with `be_approx` and `be_approx_within` custom matchers for RSpec integration

## [0.5.0] - 2026-04-10

### Added
- `Comparator#relative_equal?` for relative tolerance using configured tolerances
- `Comparator#clamp` to snap values using configured epsilon
- `Comparator#zero?` for approximate-zero checks using configured epsilon
- `Comparator#between?` for range checks using configured epsilon
- `Comparator#assert_within` assertion using configured tolerances

## [0.4.0] - 2026-04-09

### Added
- `zero?(value, epsilon:)` helper for approximate-zero checks
- `between?(value, min, max, epsilon:)` for tolerance-aware range checks
- `assert_within(a, b, abs:, rel:)` assertion mirror of `within?`
- `Comparator#near?` and `Comparator#within?` for parity with module methods

## [0.3.0] - 2026-04-04

### Added
- `clamp(value, target, epsilon:)` method to snap near-values to a target

## [0.2.0] - 2026-04-03

### Added
- Relative tolerance comparison via `relative_equal?`
- Combined tolerance mode via `within?` (absolute + relative)
- Reusable `Comparator` object with preset tolerances

## [0.1.7] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.6] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.5] - 2026-03-24

### Changed
- Expand README API table to document all public methods

## [0.1.4] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements

## [0.1.3] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes

## [0.1.2] - 2026-03-22

### Changed
- Expanded test coverage to 30+ examples covering edge cases, error paths, and boundary conditions

## [0.1.1] - 2026-03-22

### Changed
- Version bump for republishing

## [0.1.0] - 2026-03-22

### Added
- Initial release
- Epsilon-based approximate equality for floats
- Deep comparison for arrays and hashes
- Assert method that raises on mismatch
