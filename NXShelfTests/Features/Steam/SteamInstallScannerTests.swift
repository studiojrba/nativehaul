import Foundation
@testable import NXShelf
import Testing

struct SteamInstallScannerTests {
    private let fileManager = FileManager.default

    private func write(_ root: URL, _ relative: String, _ text: String) throws {
        let url = root.appendingPathComponent(relative)
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    private func manifest(_ appID: Int, _ name: String, size: Int = 1000) -> String {
        "\"AppState\"\n{\n\t\"appid\"\t\t\"\(appID)\"\n\t\"name\"\t\t\"\(name)\"\n\t\"SizeOnDisk\"\t\t\"\(size)\"\n}\n"
    }

    @Test func findsMacAndBottleInstallsIncludingExtraLibraries() throws {
        let root = fileManager.temporaryDirectory.appendingPathComponent("NXShelfSteam-\(UUID().uuidString)")
        defer { try? fileManager.removeItem(at: root) }
        let mac = root.appendingPathComponent("MacSteam")
        let bottles = root.appendingPathComponent("Bottles")
        let extraLibrary = root.appendingPathComponent("External/SteamLibrary")
        try write(mac, "steamapps/appmanifest_620.acf", manifest(620, "Portal 2", size: 12000))
        try write(mac, "steamapps/appmanifest_228980.acf", manifest(228_980, "Steamworks Common Redistributables"))
        try write(
            mac,
            "steamapps/libraryfolders.vdf",
            "\"libraryfolders\"\n{\n\t\"1\"\n\t{\n\t\t\"path\"\t\t\"\(extraLibrary.path)\"\n\t}\n}"
        )
        try write(extraLibrary, "steamapps/appmanifest_400.acf", manifest(400, "Portal"))
        let bottleSteam = "Gaming/drive_c/Program Files (x86)/Steam"
        try write(bottles, "\(bottleSteam)/steamapps/appmanifest_620.acf", manifest(620, "Portal 2", size: 15000))
        try write(
            bottles, "\(bottleSteam)/steamapps/libraryfolders.vdf",
            "\"libraryfolders\"\n{\n\t\"1\"\n\t{\n\t\t\"path\"\t\t\"C:\\\\Games\\\\SteamLibrary\"\n\t}\n}"
        )
        try write(bottles, "Gaming/drive_c/Games/SteamLibrary/steamapps/appmanifest_70.acf", manifest(70, "Half-Life"))

        let installs = SteamInstallScanner().scanInstalls(roots: SteamInstallRoots(
            macSteamRoot: mac.path, bottlesRoot: bottles.path
        ))

        let mac620 = installs.filter { $0.appID == 620 && $0.location.kind == .mac }
        #expect(mac620.count == 1)
        #expect(mac620.first?.sizeOnDisk == 12000)
        #expect(installs.contains { $0.appID == 400 && $0.location == .mac })
        #expect(!installs.contains { $0.appID == 228_980 })
        let bottle = installs.filter { $0.location.kind == .crossOver }
        #expect(Set(bottle.map(\.appID)) == [620, 70])
        #expect(bottle.allSatisfy { $0.location.bottle == "Gaming" })
        #expect(bottle.first?.location.displayName == "Steam (CrossOver — Gaming)")
    }

    @Test func missingRootsYieldNothing() {
        let roots = SteamInstallRoots(macSteamRoot: "/nonexistent/a", bottlesRoot: "/nonexistent/b")
        #expect(SteamInstallScanner().scanInstalls(roots: roots).isEmpty)
    }

    @Test func keyValuesAndWindowsPaths() {
        let text = "\"path\"\t\t\"D:\\\\Games\\\\Lib\"\n\"Name\" \"Say \\\"hi\\\"\""
        #expect(SteamKeyValues.value(forKey: "path", in: text) == "D:\\Games\\Lib")
        #expect(SteamKeyValues.value(forKey: "name", in: text) == "Say \"hi\"")
        #expect(WindowsPath.macPath(for: "C:\\Games\\Lib", inBottle: "/b/X") == "/b/X/drive_c/Games/Lib")
        #expect(WindowsPath.macPath(for: "D:\\Lib", inBottle: "/b/X") == "/b/X/dosdevices/d:/Lib")
        #expect(WindowsPath.macPath(for: "relative", inBottle: "/b/X") == nil)
        #expect(
            WindowsPath.windowsPath(for: "/b/X/drive_c/Program Files (x86)/Steam/steam.exe", inBottle: "/b/X")
                == "C:\\Program Files (x86)\\Steam\\steam.exe"
        )
    }
}
