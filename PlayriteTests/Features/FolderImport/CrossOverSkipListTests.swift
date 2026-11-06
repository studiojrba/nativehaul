@testable import Playrite
import Testing

struct CrossOverSkipListTests {
    @Test(arguments: [
        "Common Files", "Microsoft.NET", "Windows NT", "Internet Explorer", "Steam", "Epic Games",
        "Microsoft Visual C++ Redist", "DirectX", "Game Setup Files", "Uninstall Information", "CrashReporter",
    ])
    func skipsNonGameFolders(_ name: String) {
        #expect(CrossOverSkipList.shouldSkipFolder(named: name))
    }

    @Test(arguments: ["Lanternfall", "Hollow Knight", "Disco Elysium"])
    func keepsGameFolders(_ name: String) {
        #expect(!CrossOverSkipList.shouldSkipFolder(named: name))
    }

    @Test(arguments: [
        "unins000.exe", "Uninstall.exe", "setup.exe", "vcredist_x64.exe", "DXSETUP.exe",
        "UnityCrashHandler64.exe", "CrashReportClient.exe", "EasyAntiCheat_Setup.exe", "Updater.exe", "readme.txt",
    ])
    func rejectsNonGameExecutables(_ name: String) {
        #expect(!CrossOverSkipList.isPlausibleGameExecutable(name))
    }

    @Test(arguments: ["Lanternfall.exe", "Game.EXE", "Win64-Shipping.exe"])
    func acceptsGameExecutables(_ name: String) {
        #expect(CrossOverSkipList.isPlausibleGameExecutable(name))
    }
}
