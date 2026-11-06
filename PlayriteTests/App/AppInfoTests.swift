@testable import Playrite
import Testing

struct AppInfoTests {
    @Test func productNameIsPlayrite() {
        #expect(AppInfo.productName == "Playrite")
    }
}
