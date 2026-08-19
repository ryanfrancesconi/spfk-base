// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

#if os(macOS)

    import AppKit

    extension NSPasteboard.PasteboardType {
        /// Every Spongefork JSON payload is declared under a type beginning here, which is what
        /// lets a reader separate "a payload of some other type" from "text this app never wrote".
        public static let spfkSerializablePrefix = "com.spongefork.serializable."
    }

    extension NSPasteboard {
        /// Whether the board carries a Spongefork JSON payload, of any type.
        public var hasSerializablePayload: Bool {
            types?.contains { $0.rawValue.hasPrefix(PasteboardType.spfkSerializablePrefix) } ?? false
        }
    }

    extension Serializable {
        /// The board type this payload's JSON is written under, distinct per conforming type.
        public static var pasteboardType: NSPasteboard.PasteboardType {
            .init(NSPasteboard.PasteboardType.spfkSerializablePrefix + pasteboardTypeName)
        }

        /// Defaults to `.general`. Pass a uniquely named board to keep a caller off the
        /// machine-wide one, which every process on the system — and the user's own clipboard —
        /// is contending for.
        ///
        /// Written under both the typed representation and `.string`, so a reader that knows the
        /// type can identify it while another app still sees the JSON as text.
        public func toPasteboard(_ pasteboard: NSPasteboard = .general) throws {
            guard let jsonRepresentation else {
                throw NSError(description: "Failed to convert \(self) to JSON")
            }

            pasteboard.clearContents()
            pasteboard.declareTypes([Self.pasteboardType, .string], owner: nil)
            pasteboard.setString(jsonRepresentation, forType: Self.pasteboardType)
            pasteboard.setString(jsonRepresentation, forType: .string)
        }

        /// Reads the typed representation, falling back to `.string` only when the board carries no
        /// Spongefork payload at all.
        ///
        /// Without that condition the fallback undoes the typing: a permissive decode — one whose
        /// every field is optional — accepts another type's JSON and yields an empty instance,
        /// which is indistinguishable from a real one.
        public static func fromPasteboard<T: Serializable>(_ pasteboard: NSPasteboard = .general) throws -> T {
            if let json = pasteboard.string(forType: T.pasteboardType) {
                return try T(json: json)
            }

            guard !pasteboard.hasSerializablePayload else {
                throw NSError(description: "Pasteboard holds a payload other than \(T.pasteboardTypeName)")
            }

            guard let string = pasteboard.string(forType: .string) else {
                throw NSError(description: "Invalid pasteboard contents, must be .string")
            }

            return try T(json: string)
        }
    }

#endif
