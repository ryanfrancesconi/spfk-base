// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// A stored value whose missing keys decode as the matching keys of a default value.
public protocol DefaultFilledDecodable: Codable {
    /// What a missing key takes.
    static var decodingDefaults: Self { get }

    /// `data` decoded with its missing keys taken from `decodingDefaults`.
    static func decodeFillingGaps(from data: Data, using decoder: JSONDecoder) throws -> Self
}

extension DefaultFilledDecodable {
    public static func decodeFillingGaps(from data: Data, using decoder: JSONDecoder = JSONDecoder()) throws -> Self {
        try decoder.decode(Self.self, from: data, fillingGapsFrom: decodingDefaults)
    }
}

extension JSONDecoder {
    /// `data` decoded strictly after merging it over `defaults` encoded: a key `data` lacks, at any
    /// depth, takes the default's value. Objects merge key by key; arrays and scalars are replaced whole.
    ///
    /// `defaults` is encoded with a plain `JSONEncoder`, so this decoder's strategies must read what
    /// that writes. An optional `data` omitted as nil takes the default's value.
    public func decode<T: Codable>(_ type: T.Type, from data: Data, fillingGapsFrom defaults: T) throws -> T {
        let stored = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        let filler = try JSONSerialization.jsonObject(with: JSONEncoder().encode(defaults), options: .fragmentsAllowed)

        guard let stored = stored as? [String: Any], let filler = filler as? [String: Any] else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "A \(T.self) to fill from defaults is not a JSON object")
            )
        }

        let merged = try JSONSerialization.data(withJSONObject: Self.merge(stored, over: filler))
        return try decode(T.self, from: merged)
    }

    private static func merge(_ stored: [String: Any], over defaults: [String: Any]) -> [String: Any] {
        var merged = defaults

        for (key, value) in stored {
            if let nested = value as? [String: Any], let nestedDefault = defaults[key] as? [String: Any] {
                merged[key] = merge(nested, over: nestedDefault)
            } else {
                merged[key] = value
            }
        }

        return merged
    }
}
