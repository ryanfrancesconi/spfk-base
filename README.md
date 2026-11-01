# SPFKBase
[![Version](https://img.shields.io/github/v/tag/ryanfrancesconi/spfk-base)](https://github.com/ryanfrancesconi/spfk-base/tags)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-base%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-base)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-base%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-base)

The floor of the Spongefork packages. Every other package reaches it, directly or transitively, and
nothing uses it on its own.

It holds what any layer might need and that knows nothing about a domain or a screen: Foundation and
standard-library extensions, logging, small value types shared by audio, image and video work,
cooperative stopping and progress reporting for parse passes, running a child process, and catching
Objective-C exceptions from Swift through its companion C module.

## Scope

spfk-base is Foundation-level and imports no AppKit. A utility that needs AppKit, the file system
layer or image decoding belongs in spfk-utils, which sits above it. A type comes down here only when
packages that cannot depend on each other both need it; audio vocabulary belongs in spfk-audio-base,
time in spfk-time.

## Constraints

Debug logging is gated at runtime by `Log.buildConfig`, which the app sets at launch. It defaults to
debug, so an app that never sets it logs debug output in a release build.

A parse pass is stopped through `ParseStopSignal`, not by cancelling its task: cancelling in the
middle of an `AVAsset` load leaks the continuation behind it.

## About

Spongefork is the personal software projects of musician and developer [Ryan Francesconi](https://spongefork.com). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2026, Spongefork returns as his software container for more musical experimentation. In addition to [software releases](https://spongefork.com/shadowtag/), open source components can be found on his [GitHub page](https://github.com/ryanfrancesconi).
