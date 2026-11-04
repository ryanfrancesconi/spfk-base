// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

extension Error {
    /// The error's description, or nil when it is Foundation's fallback, which names only a domain
    /// and code: "The operation couldn't be completed. (<domain> error <code>.)".
    ///
    /// The fallback is what a bare OSStatus, an undescribed Swift error, or `_GenericObjCError` (an
    /// Objective-C call that failed without setting its error) shows. Only the closing ` error
    /// <code>.)` is matched: the sentence before it is localized, and some domains print a short
    /// name ("OSStatus") instead of themselves.
    public var informativeDescription: String? {
        let error = self as NSError
        let description = error.localizedDescription

        guard !description.isEmpty, !description.hasSuffix(" error \(error.code).)") else { return nil }
        return description
    }

    /// What the error says, to show after a headline: its description, or only the domain and code
    /// when the description is Foundation's fallback.
    public var messageDetail: String {
        informativeDescription ?? fallbackCode ?? (self as NSError).localizedDescription
    }

    /// `headline` followed by what the error says: its description on the next line, or only the
    /// parenthesized domain and code when the description is Foundation's fallback.
    public func message(headline: String) -> String {
        if let informativeDescription {
            return headline + "\n" + informativeDescription
        }

        guard let fallbackCode else { return headline }
        return "\(headline) (\(fallbackCode))"
    }

    /// "<domain> error <code>", from the parentheses closing Foundation's fallback description.
    private var fallbackCode: String? {
        let description = (self as NSError).localizedDescription

        guard let open = description.lastIndex(of: "(") else { return nil }

        return description[open...].trimmingCharacters(in: CharacterSet(charactersIn: "().").union(.whitespaces))
    }
}
