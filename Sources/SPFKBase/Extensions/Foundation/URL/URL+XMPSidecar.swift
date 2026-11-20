// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation
import UniformTypeIdentifiers

/// A file's XMP sidecar: `<basename>.xmp` beside it, the name Adobe's apps read and write.
extension URL {
    /// Whether this file's metadata belongs in a sidecar: a camera RAW other than DNG, by extension.
    public var usesXMPSidecar: Bool {
        guard let type = UTType(filenameExtension: pathExtension) else { return false }
        return type.conforms(to: .rawImage) && !type.conforms(to: Self.dngType)
    }

    /// The sidecar's URL: an existing sibling named `<basename>.xmp` in any case, else that name in
    /// lower case. Answered whether or not the file uses a sidecar.
    public var xmpSidecarURL: URL {
        let folder = deletingLastPathComponent()
        let base = deletingPathExtension().lastPathComponent

        for pathExtension in ["xmp", "XMP"] {
            let candidate = folder.appendingPathComponent(base).appendingPathExtension(pathExtension)
            guard FileManager.default.fileExists(atPath: candidate.path) else { continue }

            // A case-insensitive volume finds either spelling; the name on disk is the one to use.
            guard let name = try? candidate.resourceValues(forKeys: [.nameKey]).name else { return candidate }
            return folder.appendingPathComponent(name)
        }

        return folder.appendingPathComponent(base).appendingPathExtension("xmp")
    }

    /// The sidecar's URL when this file uses one and it exists on disk.
    public var existingXMPSidecarURL: URL? {
        guard usesXMPSidecar else { return nil }
        let sidecar = xmpSidecarURL
        return FileManager.default.fileExists(atPath: sidecar.path) ? sidecar : nil
    }

    private static let dngType = UTType("com.adobe.raw-image") ?? .rawImage
}
