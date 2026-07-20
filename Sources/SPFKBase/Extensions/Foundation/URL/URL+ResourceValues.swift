// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation
import UniformTypeIdentifiers

// MARK: - resourceValues, see URLTag for tag names

extension URL {
    public var mimeType: String {
        let genericType = "application/octet-stream"

        guard let type = UTType(filenameExtension: pathExtension),
              let mimetype = type.preferredMIMEType
        else {
            // hack, this isn't coming through.
            if pathExtension == "caf" {
                return "audio/x-caf"
            }

            return genericType
        }

        return mimetype
    }

    public var utType: UTType? {
        try? resourceValues(forKeys: [.contentTypeKey]).contentType
    }

    public var documentKind: String? {
        guard let value = try? resourceValues(forKeys: [.contentTypeKey]) else { return nil }
        return value.contentType?.localizedDescription
    }

    public var creationDate: Date? {
        guard let value = try? resourceValues(forKeys: [.creationDateKey]) else { return nil }
        return value.creationDate
    }

    /// When the file's contents (the data stream) were last written to.
    public var contentModificationDate: Date? {
        guard let value = try? resourceValues(forKeys: [.contentModificationDateKey]) else { return nil }
        return value.contentModificationDate
    }

    /// This date reflects when any of the file's metadata (attributes) were last modified
    public var attributeModificationDate: Date? {
        guard let value = try? resourceValues(forKeys: [.attributeModificationDateKey]) else { return nil }
        return value.attributeModificationDate
    }

    /// Returns the most recent modification date after refreshing, content or attribute
    public var modificationDate: Date? {
        var uncached = self

        uncached.removeCachedResourceValue(forKey: .contentModificationDateKey)
        uncached.removeCachedResourceValue(forKey: .attributeModificationDateKey)

        guard let contentModificationDate = uncached.contentModificationDate,
              let attributeModificationDate = uncached.attributeModificationDate
        else { return nil }

        if contentModificationDate > attributeModificationDate {
            return contentModificationDate
        }

        return attributeModificationDate
    }

    public var isDirectory: Bool {
        guard let value = try? resourceValues(forKeys: [.isDirectoryKey]) else { return false }
        return value.isDirectory == true
    }

    public var isPackage: Bool {
        guard let value = try? resourceValues(forKeys: [.isPackageKey]) else { return false }
        return value.isPackage == true
    }

    public var isDirectoryOrPackage: Bool {
        isDirectory || isPackage
    }

    public var isAlias: Bool {
        guard let value = try? resourceValues(forKeys: [.isAliasFileKey, .isSymbolicLinkKey]) else { return false }
        return value.isAliasFile == true || value.isSymbolicLink == true
    }

    public var isHidden: Bool {
        guard !lastPathComponent.hasPrefix(".") else { return true }

        guard let value = try? resourceValues(forKeys: [.isHiddenKey]) else { return false }
        return value.isHidden == true
    }
}

#if os(macOS)
    extension URL {
        public var lastOpened: Date? {
            let itemRef = MDItemCreateWithURL(nil, self as CFURL)
            return MDItemCopyAttribute(itemRef, kMDItemLastUsedDate) as? Date
        }
    }
#endif // os(macOS)
