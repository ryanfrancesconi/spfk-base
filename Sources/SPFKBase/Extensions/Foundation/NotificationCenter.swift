// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

extension NotificationCenter {
    /// Useful for sending a notification and waiting for the result
    /// - Parameter notificationName: name to wait for
    /// - Parameter timeout: pass `nil` to wait forever
    /// - Returns: the `Notification`
    public static func wait(
        for notificationName: Notification.Name,
        timeout: TimeInterval? = 10
    ) async throws -> Notification {
        let notification = try await withThrowingTaskGroup(
            of: SendableNotification.self,
            returning: Notification?.self
        ) { taskGroup in

            taskGroup.addTask {
                let asyncSequence = NotificationCenter.default.notifications(named: notificationName)
                let iterator = asyncSequence.makeAsyncIterator()

                guard let notification = await iterator.next() else {
                    throw NSError(description: "Failed to get \(notificationName)")
                }

                return SendableNotification(notification)
            }

            if let timeout {
                taskGroup.addTask {
                    try await Task.sleep(seconds: timeout)
                    Log.error("* Test timed out")
                    return SendableNotification(nil)
                }
            }

            let value: SendableNotification? = try await taskGroup.next()
            taskGroup.cancelAll()

            return value?.notification
        }

        guard let notification else {
            throw NSError(description: "Failed to get \(notificationName) due to timeout")
        }

        return notification
    }
}

public struct SendableNotification: @unchecked Sendable {
    public let notification: Notification?

    public init(_ notification: Notification?) {
        self.notification = notification
    }
}
