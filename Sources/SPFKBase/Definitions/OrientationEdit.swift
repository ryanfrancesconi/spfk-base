// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// A pending rotation or mirror, applied on top of what a file displays now. One of the 8 symmetries of
/// the square, each with the EXIF orientation value that performs it.
///
/// `.up` is no edit. A file's new orientation tag is ``applied(toFileOrientation:)``.
public enum OrientationEdit: Int, Codable, Sendable, Hashable, CaseIterable {
    case up = 1
    case upMirrored = 2
    case down = 3
    case downMirrored = 4
    case leftMirrored = 5
    case right = 6
    case rightMirrored = 7
    case left = 8

    /// A user command, acting on the media as it is displayed.
    public enum Command: Sendable, Hashable, CaseIterable {
        case rotateLeft
        case rotateRight
        case flipHorizontal
        case flipVertical

        /// The edit that performs this command on its own.
        public var edit: OrientationEdit {
            switch self {
            case .rotateLeft: .left
            case .rotateRight: .right
            case .flipHorizontal: .upMirrored
            case .flipVertical: .downMirrored
            }
        }
    }

    public var isIdentity: Bool { self == .up }

    /// Whether the displayed width and height trade places.
    public var swapsDimensions: Bool { quarterTurns % 2 == 1 }

    /// `command` performed after this edit, in display space.
    public func applying(_ command: Command) -> OrientationEdit {
        command.edit.composed(after: self)
    }

    public var rotatedLeft: OrientationEdit { applying(.rotateLeft) }
    public var rotatedRight: OrientationEdit { applying(.rotateRight) }
    public var flippedHorizontally: OrientationEdit { applying(.flipHorizontal) }
    public var flippedVertically: OrientationEdit { applying(.flipVertical) }

    /// The orientation tag that displays a file tagged `fileOrientation` with this edit performed.
    /// An out-of-range tag reads as 1, as ImageIO treats it.
    public func applied(toFileOrientation fileOrientation: Int) -> Int {
        composed(after: OrientationEdit(rawValue: fileOrientation) ?? .up).rawValue
    }

    // MARK: - Composition

    /// Clockwise quarter turns, 0-3, performed after the left-right mirror when ``isMirrored``.
    public var quarterTurns: Int {
        switch self {
        case .up, .upMirrored: 0
        case .right, .rightMirrored: 1
        case .down, .downMirrored: 2
        case .left, .leftMirrored: 3
        }
    }

    /// Whether a left-right mirror is performed before ``quarterTurns``.
    public var isMirrored: Bool {
        switch self {
        case .upMirrored, .downMirrored, .leftMirrored, .rightMirrored: true
        default: false
        }
    }

    /// Any number of turns, reduced modulo 4.
    public init(quarterTurns: Int, isMirrored: Bool) {
        let turns = ((quarterTurns % 4) + 4) % 4

        self = Self.allCases.first { $0.quarterTurns == turns && $0.isMirrored == isMirrored } ?? .up
    }

    /// This edit performed after `other`. A mirror reverses the direction of any turn performed before it.
    public func composed(after other: OrientationEdit) -> OrientationEdit {
        OrientationEdit(
            quarterTurns: quarterTurns + (isMirrored ? -other.quarterTurns : other.quarterTurns),
            isMirrored: isMirrored != other.isMirrored
        )
    }
}
