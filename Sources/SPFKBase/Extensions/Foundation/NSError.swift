// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

extension NSError {
    public convenience init(
        domain: String = Log.defaultSubsystem,
        code: Int = 1,
        description: String
    ) {
        let userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: description,
        ]

        self.init(
            domain: domain,
            code: code,
            userInfo: userInfo
        )
    }

    public convenience init(
        domain: String = Log.defaultSubsystem,
        code: Int = 1,
        file: String,
        function: String,
        description: String,
    ) {
        let fileName = (file as NSString).lastPathComponent
        let message = "\(fileName):\(function):" + description

        let userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: message,
        ]

        self.init(
            domain: domain,
            code: code,
            userInfo: userInfo
        )
    }
}
