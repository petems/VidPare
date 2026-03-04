import SwiftUI

@main
struct VidPareApp: App {
  init() {
    NSApplication.shared.setActivationPolicy(.regular)
    NSApplication.shared.activate(ignoringOtherApps: true)
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .windowStyle(.titleBar)
    .defaultSize(width: 960, height: 640)
    .commands {
      CommandGroup(replacing: .newItem) {}
    }
  }
}
