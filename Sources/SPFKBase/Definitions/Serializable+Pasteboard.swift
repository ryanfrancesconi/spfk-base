// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

#if os(macOS)

    import AppKit

    extension Serializable {
        public func toPasteboard() throws {
            guard let jsonRepresentation else {
                throw NSError(description: "Failed to convert \(self) to JSON")
            }

            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(jsonRepresentation, forType: .string)
        }

        public static func fromPasteboard<T: Serializable>() throws -> T {
            let pasteboard = NSPasteboard.general

            guard let string = pasteboard.string(forType: .string) else {
                throw NSError(description: "Invalid pasteboard contents, must be .string")
            }

            return try T(json: string)
        }
    }

#endif
