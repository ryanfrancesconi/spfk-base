// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

extension FileManager {
    public func modificationDateForFileAtPath(path: String) -> Date? {
        guard let attributes = try? attributesOfItem(atPath: path) else { return nil }
        return attributes[.modificationDate] as? Date
    }

    public func creationDateForFileAtPath(path: String) -> Date? {
        guard let attributes = try? attributesOfItem(atPath: path) else { return nil }
        return attributes[.creationDate] as? Date
    }

    public func isInTrash(_ url: URL) -> Bool {
        var relationship: URLRelationship = .other

        try? getRelationship(
            &relationship,
            of: .trashDirectory,
            in: .allDomainsMask,
            toItemAt: url
        )

        return relationship == .contains
    }
}
