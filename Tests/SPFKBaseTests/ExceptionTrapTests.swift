import AVFoundation
import Foundation
import SPFKBase
import SPFKBaseC
import Testing

class ExceptionTrapTests: TestCaseModel {
    var object: Object? = Object()

    class Object {
        init() {}

        func throwError() throws {
            throw NSError(description: #function)
        }

        func throwObjException() {
            AVAudioPlayerNode().play()
        }

        func noException() {
            _ = AVAudioPlayerNode()
        }
    }

    @Test func swiftErrorWithSelf() async throws {
        Log.signpost(.begin, name: "throwError")
        #expect(throws: Error.self) {
            try ExceptionTrap.withThrowing { [weak self] in
                try self?.object?.throwError()
            }
        }

        object = nil
        Log.signpost(.end, name: "throwError")
    }

    @Test func nsError() async throws {
        try await wait(sec: 4)

        Log.signpost(.begin, name: "throwError")

        #expect(throws: Error.self) {
            try ExceptionTrap.withThrowing { [weak self] in
                self?.object?.throwObjException()
            }
        }

        object = nil
        Log.signpost(.end, name: "throwError")

        try await wait(sec: 5)
    }

    @Test func noError() async throws {
        Log.signpost(.begin, name: "throwError")

        try ExceptionTrap.withThrowing { [weak self] in
            self?.object?.noException()
        }

        object = nil
        Log.signpost(.end, name: "throwError")
    }

    @Test func exceptionCatcher() async throws {
        try await wait(sec: 4)

        Log.signpost(.begin, name: "throwError")

        ExceptionCatcherOperation({ [weak self] in
            self?.object?.throwObjException()

        }, { exception in
            Log.error(exception)
        })

        object = nil
        Log.signpost(.end, name: "throwError")

        try await wait(sec: 5)
    }
}
