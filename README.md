# SPFKBase
[![CI](https://img.shields.io/github/actions/workflow/status/ryanfrancesconi/spfk-base/ci.yml?branch=development)](https://github.com/ryanfrancesconi/spfk-base/actions/workflows/ci.yml)
[![Version](https://img.shields.io/github/v/tag/ryanfrancesconi/spfk-base)](https://github.com/ryanfrancesconi/spfk-base/tags)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-base%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-base)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-base%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-base)

The foundational layer for the SPFK package ecosystem. SPFKBase provides core utilities, type extensions, and shared infrastructure used across all SPFK packages.

## Overview

SPFKBase is a Swift package containing common extensions, type definitions, logging, and testing utilities that form the base dependency for higher-level SPFK packages. It includes a companion Objective-C/C++ module (`SPFKBaseC`) for bridging Objective-C exception handling into Swift.

## Requirements

- **Platforms:** macOS 13+, iOS 16+
- **Swift:** 6.2+

## Features

### Logging

A lightweight logging layer built on Apple's `os_log` system with categorized log channels (info, debug, error, points-of-interest) and build-configuration gating. Debug and verbose logging is automatically stripped from release builds.

### Exception Handling

Bridges Objective-C `@try`/`@catch` exception handling into Swift through the `SPFKBaseC` module, allowing Swift code to safely catch Objective-C exceptions that would otherwise be fatal.

### Type Definitions

- **`MovementDirection`** -- An enum representing directional movement (up/down) with numeric, boolean, and string conversions.
- **`FloatChannelData`** -- A multi-channel floating-point buffer backed by `UnsafeMutablePointer<UnsafeMutablePointer<Float>?>`, used for interleaved/deinterleaved audio data.
- **`UnitInterval`** -- A type-safe wrapper constraining floating-point values to the 0...1 range.
- **`Benchmark`** -- A simple start/stop timer for measuring execution duration of code blocks.

### Extensions

#### String
- ASCII filtering, whitespace normalization, abbreviation from camelCase/PascalCase names
- Spaced title-case conversion, case-insensitive comparison, standard locale-aware sorting
- Delimiter-based splitting, boolean parsing, URL encoding
- C-string interop utilities

#### Collections
- Generalized element movement (bring-to-front, send-to-back, move by offset)
- Quantity descriptions with pluralization ("1 item" vs "3 items")
- Delimited string joining with configurable separators and terminal conjunctions
- Case-insensitive string search, numeric type conversions (`compactMap` to `Int`, `UInt32`, `Double`)

#### Floating Point
- Rounding to arbitrary divisors with configurable rounding rules
- Array mean/average computation for `Float` and `Double` collections
- Unit interval range (`0...1`) as a static property

#### URL
- File existence, readability, and size checks
- Remote URL detection, path containment tests, tilde resolution
- Directory creation, listing, emptiness checks, and deletion
- MIME type lookup via `UTType`, resource value accessors (dates, hidden, alias/symlink detection)
- Query string construction with percent-encoding

#### Bool
- Initialization from any `BinaryInteger` (zero is `false`, non-zero is `true`)

#### NSError / NSException
- Convenience initializers for `NSError` with description, domain, code, and source location
- `NSException` to `NSError` conversion preserving call stack information

#### Geometry
- `NSRect` construction from `NSSize`, `CGFloat` pairs, and `Int` pairs
- Center-point computation for `NSRect`

#### Other
- `FileManager` extensions for file date retrieval
- `NotificationCenter` async observation helpers
- `Task` cancellation utilities
- `AsyncSequence` collection into arrays
- `FourCharCode` (`UInt32`) string conversion for Audio Unit type identifiers
- `TypeDescribable` protocol for runtime type name access

### Testing Utilities

- **`TestCaseModel`** -- A protocol for test fixtures that manages temporary directories and provides access to bundled test resources.
- **`BinTestCase`** -- A specialized test case model for binary/audio file testing with automatic cleanup.

## Dependencies

- [swift-extensions](https://github.com/orchetect/swift-extensions)
- [swift-numerics](https://github.com/apple/swift-numerics)
- [swift-collections](https://github.com/apple/swift-collections)
- [swift-async-algorithms](https://github.com/apple/swift-async-algorithms)
- [spfk-testing](https://github.com/ryanfrancesconi/spfk-testing) (test target only)

## Installation

Add SPFKBase to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ryanfrancesconi/spfk-base", from: "0.0.5"),
]
```

Then add it as a dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "SPFKBase", package: "spfk-base"),
    ]
)
```

## License

Copyright Ryan Francesconi. All Rights Reserved.

## About

Spongefork is the personal software projects of musician and developer [Ryan Francesconi](https://spongefork.com). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2026, Spongefork returns as his software container for more musical experimentation. In addition to [software releases](https://spongefork.com/shadowtag/), open source components can be found on his [GitHub page](https://github.com/ryanfrancesconi).
