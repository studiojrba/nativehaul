@testable import Playrite
import Testing

struct SteamIDTests {
    @Test(arguments: ["76561197960287930", " 76561197960287930 "])
    func acceptsValid(input: String) {
        #expect(SteamID(input)?.rawValue == "76561197960287930")
    }

    @Test(arguments: ["", "123", "7656119796028793a", "12345678901234567", "765611979602879300", "７６５６１１９７９６０２８７９３０"])
    func rejectsInvalid(input: String) {
        #expect(SteamID(input) == nil)
    }
}
