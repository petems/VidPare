import ApplicationServices
import AXAutomation
import XCTest

final class PlayerControlsInteractionTests: XCTestCase {
  private let launcher = AppLauncher()
  private var pid: pid_t = 0

  private var fixturePath: String {
    let cwd = FileManager.default.currentDirectoryPath
    return "\(cwd)/Tests/VidPareTests/Fixtures/sample.mp4"
  }

  override func setUpWithError() throws {
    try super.setUpWithError()

    guard AXIsProcessTrusted() else {
      throw XCTSkip(
        "Accessibility permissions required. Add Terminal (or your IDE) to "
          + "System Settings > Privacy & Security > Accessibility."
      )
    }

    guard FileManager.default.fileExists(atPath: fixturePath) else {
      throw XCTSkip("Missing fixture: \(fixturePath)")
    }

    pid = try launcher.launch(environment: ["VIDPARE_OPEN_FILE": fixturePath])
  }

  override func tearDown() {
    launcher.terminate()
    super.tearDown()
  }

  // MARK: - Player Controls

  func testVideoLoads_playerControlsVisible() {
    let app = axApp(for: pid)

    var playPauseButton: AXUIElement?
    var soundToggleButton: AXUIElement?

    let found = waitFor(timeout: 10.0) {
      guard let window = axWindows(of: app).first else { return false }
      playPauseButton = findElement(withIdentifier: "vidpare.playPause", in: window)
      soundToggleButton = findElement(withIdentifier: "vidpare.soundToggle", in: window)
      return playPauseButton != nil && soundToggleButton != nil
    }

    XCTAssertTrue(found, "Player controls should show play/pause and sound toggle")
    XCTAssertNotNil(playPauseButton, "Play/Pause button should be present")
    XCTAssertNotNil(soundToggleButton, "Sound toggle button should be present")
  }

  func testPlayerControls_buttonsAreInteractive() {
    let app = axApp(for: pid)

    var playPauseButton: AXUIElement?
    var soundToggleButton: AXUIElement?

    let found = waitFor(timeout: 10.0) {
      guard let window = axWindows(of: app).first else { return false }
      playPauseButton = findElement(withIdentifier: "vidpare.playPause", in: window)
      soundToggleButton = findElement(withIdentifier: "vidpare.soundToggle", in: window)
      return playPauseButton != nil && soundToggleButton != nil
    }
    guard found, let playPauseButton, let soundToggleButton else {
      return XCTFail("Player controls did not appear")
    }

    XCTAssertTrue(pressButton(playPauseButton), "Play/Pause should be pressable")
    XCTAssertTrue(pressButton(playPauseButton), "Play/Pause should be pressable repeatedly")
    XCTAssertTrue(pressButton(soundToggleButton), "Sound toggle should be pressable")
    XCTAssertTrue(pressButton(soundToggleButton), "Sound toggle should be pressable repeatedly")
  }
}
