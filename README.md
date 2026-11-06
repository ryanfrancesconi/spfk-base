# SPFKBase
[![Version](https://img.shields.io/github/v/tag/ryanfrancesconi/spfk-base)](https://github.com/ryanfrancesconi/spfk-base/tags)
[![Swift](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-base%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-base)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-base%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-base)

Foundation and standard library extensions shared by the Spongefork packages.

## Features

- Logging (`Log`)
- Small value types shared by audio, image and video code
- Cooperative stopping (`ParseStopSignal`) and progress reporting for parse passes
- Running a child process (`ProcessRunner`)
- Catching Objective-C exceptions from Swift (`ExceptionTrap`)

## Notes

- `Log.buildConfig` defaults to `.debug`. Set it at launch, or a release build logs debug output.
- Stop a parse pass with `ParseStopSignal` rather than cancelling its task. Cancelling during an
  `AVAsset` load leaks the continuation behind it.

## About

Spongefork is the personal software projects of musician and developer [Ryan Francesconi](https://spongefork.com). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2026, Spongefork returns as his software container for more musical experimentation. In addition to [software releases](https://spongefork.com/shadowtag/), open source components can be found on his [GitHub page](https://github.com/ryanfrancesconi).
