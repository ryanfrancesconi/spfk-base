import Foundation
@testable import SPFKBase
import Testing

class FourCharCodeTests: TestCaseModel {
    @Test func convert() {
        let fcc: FourCharCode = 1869180523 //kAudioDevicePropertyHogMode

        #expect(fcc.fourCC == "oink")
        #expect("oink".fourCC == 1869180523)
        
        let rhombus = "\(FourCharCode.rhombus)\(FourCharCode.rhombus)\(FourCharCode.rhombus)\(FourCharCode.rhombus)"
        
        #expect(rhombus.fourCC == 3186606013)
        #expect(FourCharCode(3186606013).fourCC == "????")
        
        #expect("oin".fourCC == nil)
        #expect(FourCharCode(0).fourCC == FourCharCode.unknown)
    }
}
