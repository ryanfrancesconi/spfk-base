// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

#if os(macOS)

    import AppKit

    extension Serializable {
        /// Defaults to `.general`. Pass a uniquely named board to keep a caller off the
        /// machine-wide one, which every process on the system — and the user's own clipboard —
        /// is contending for.
        public func toPasteboard(_ pasteboard: NSPasteboard = .general) throws {
            guard let jsonRepresentation else {
                throw NSError(description: "Failed to convert \(self) to JSON")
            }

            pasteboard.clearContents()
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(jsonRepresentation, forType: .string)
        }

        public static func fromPasteboard<T: Serializable>(_ pasteboard: NSPasteboard = .general) throws -> T {
            guard let string = pasteboard.string(forType: .string) else {
                throw NSError(description: "Invalid pasteboard contents, must be .string")
            }

            return try T(json: string)
        }
    }

#endif
