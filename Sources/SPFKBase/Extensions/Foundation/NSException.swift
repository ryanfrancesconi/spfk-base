// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

extension NSException {
    public var error: NSError {
        var info: [String: Any] = userInfo as? [String: Any] ?? .init()

        info[NSLocalizedDescriptionKey] = reason
        info["callStackSymbols"] = callStackSymbols.joined(separator: "\n")

        // Promote any NSError already in userInfo to NSUnderlyingErrorKey.
        if info[NSUnderlyingErrorKey] == nil {
            for value in info.values {
                if let nested = value as? NSError {
                    info[NSUnderlyingErrorKey] = nested
                    break
                }
            }
        }

        // AVFoundation exception reasons embed the OSStatus as "Code=<N>" when no
        // structured NSError was available in userInfo. Parse it and promote it so
        // callers can match against typed CoreAudio status codes without string matching.
        if info[NSUnderlyingErrorKey] == nil, let osStatus = parsedOSStatus {
            info[NSUnderlyingErrorKey] = NSError(domain: NSOSStatusErrorDomain, code: Int(osStatus))
        }

        return NSError(domain: name.rawValue, code: 1, userInfo: info)
    }

    // Extracts the first "Code=<N>" integer from the exception reason string.
    private var parsedOSStatus: OSStatus? {
        guard let reason,
              let match = reason.range(of: #"Code=(-?\d+)"#, options: .regularExpression),
              let numRange = reason[match].range(of: #"-?\d+"#, options: .regularExpression),
              let value = Int32(reason[numRange])
        else { return nil }
        return OSStatus(value)
    }
}

extension Error {
    /// The OSStatus embedded in this error's underlying `NSOSStatusErrorDomain` error,
    /// if one was promoted by `NSException.error` from an ObjC exception wrapped by `ExceptionTrap`.
    public var osStatus: OSStatus? {
        guard let underlying = (self as NSError).userInfo[NSUnderlyingErrorKey] as? NSError,
              underlying.domain == NSOSStatusErrorDomain
        else { return nil }
        return OSStatus(underlying.code)
    }
}
