// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import CryptoKit
import Foundation
import Testing

@testable import SPFKBase

/// `URL.sha256` is the filename four caches address their entries by, so its output is a storage
/// format rather than an implementation detail. These pin the encoding: a change here orphans every
/// cached bookmark, thumbnail, waveform and video frame on every user's disk.
@Suite
struct URLSHA256Tests {
    /// Fixed vectors, computed outside this codebase with
    /// `printf '%s' "<absoluteString>" | shasum -a 256`. A reimplementation that agreed only with
    /// its own round trip would pass every other test here and still have changed the storage key.
    @Test func matchesKnownVectors() {
        let cases: [(path: String, sha: String)] = [
            ("/", "de85814ad9cb4769a090f611dc4f82e7aa8aca812c00aa095d4ad459e8545880"),
            ("/tmp/a.wav", "b8e3a2e0e6355da9d34d21a10360f2165eb887e467030235ab39b5fd5663fee4"),
            (
                "/Users/test/Pictures/IMG_0001.heic",
                "d58cba62d97e90353dff20c8fdb187f3aeec9372acb3462a4bb1db88f504a316"
            ),
        ]

        for (path, expected) in cases {
            let url = URL(fileURLWithPath: path)
            #expect(url.sha256 == expected, "\(url.absoluteString)")
        }
    }

    /// The encoding contract: 64 lowercase hex characters, zero-padded per byte.
    @Test func isSixtyFourLowercaseHexCharacters() {
        let url = URL(fileURLWithPath: "/Users/test/Pictures/IMG_0001.heic")
        let hash = url.sha256

        #expect(hash.count == 64)
        #expect(hash.allSatisfy { $0.isHexDigit })
        #expect(hash == hash.lowercased())
    }

    /// Byte-for-byte agreement with the `String(format: "%02x")` encoding this replaced. The
    /// zero-padding is the part a hand-rolled hex loop gets wrong, and a byte below 0x10 is the only
    /// place it shows -- so this walks enough inputs to hit them.
    @Test func agreesWithTheFormatterEncoding() {
        func reference(_ url: URL) -> String {
            SHA256.hash(data: Data(url.absoluteString.utf8))
                .map { String(format: "%02x", $0) }
                .joined()
        }

        for i in 0 ..< 512 {
            let url = URL(fileURLWithPath: "/Volumes/Photos/RF SE/IMG_\(i).heic")
            #expect(url.sha256 == reference(url))
        }

        for url in [
            URL(fileURLWithPath: "/"),
            URL(fileURLWithPath: "/tmp/a b c.wav"),
            URL(fileURLWithPath: "/tmp/ünïcödé — file.mkv"),
        ] {
            #expect(url.sha256 == reference(url))
        }
    }

    @Test func differsWithTheURL() {
        let a = URL(fileURLWithPath: "/tmp/a.wav")
        let b = URL(fileURLWithPath: "/tmp/b.wav")
        #expect(a.sha256 != b.sha256)
        #expect(a.sha256 == URL(fileURLWithPath: "/tmp/a.wav").sha256)
    }
}
