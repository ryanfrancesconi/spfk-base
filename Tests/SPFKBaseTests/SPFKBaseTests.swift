@testable import SPFKBase
import Testing

struct SPFKBaseTests {
    @Test func typeDescribeable() {
        class MyClass: TypeDescribable {
            init() {}
        }

        var myStruct: MyClass? = MyClass()

        #expect(myStruct?.typeName == "MyClass")
        #expect(MyClass.typeName == "MyClass")

        myStruct = nil
    }
}
