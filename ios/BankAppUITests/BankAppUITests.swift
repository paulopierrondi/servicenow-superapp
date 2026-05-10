import XCTest

final class BankAppUITests: XCTestCase {
  func testAppLaunchesToHome() {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
  }
}
