import XCTest

final class BankAppUITests: XCTestCase {
  override func setUp() {
    continueAfterFailure = false
  }

  func testBrandSelectionOpensServiceNowCommandCenter() {
    let app = XCUIApplication()
    app.launchArguments = ["-BankAppResetBrandSelection"]
    app.launch()

    XCTAssertTrue(app.staticTexts["Escolha sua experiência"].waitForExistence(timeout: 8))
    XCTAssertTrue(app.staticTexts["SUPER APP"].exists)

    app.buttons["Entrar no Itaú"].tap()

    XCTAssertTrue(app.staticTexts["NowOS Command Center"].waitForExistence(timeout: 8))
    XCTAssertTrue(app.staticTexts["SERVICENOW SUPER APP • ITAÚ"].exists)
    XCTAssertTrue(app.staticTexts["ServiceNow como sistema operacional do super app"].exists)
  }

  func testServiceNowFirstTabsNavigateAcrossCoreExperience() {
    let app = XCUIApplication()
    app.launchArguments = ["-BankAppResetBrandSelection", "-BankAppSkipBrandSelection"]
    app.launch()

    XCTAssertTrue(app.staticTexts["NowOS Command Center"].waitForExistence(timeout: 8))

    app.tabBars.buttons["Catálogo"].tap()
    XCTAssertTrue(app.staticTexts["Orquestração por intenção"].waitForExistence(timeout: 5))
    XCTAssertTrue(
      app.staticTexts
        .containing(NSPredicate(format: "label CONTAINS %@", "Não é menu de transações."))
        .firstMatch.exists
    )

    app.tabBars.buttons["Trust"].tap()
    XCTAssertTrue(app.staticTexts["Controles antes da execução"].waitForExistence(timeout: 5))

    app.tabBars.buttons["Assist"].tap()
    XCTAssertTrue(app.staticTexts["AI operacional com handoff humano"].waitForExistence(timeout: 5))

    app.tabBars.buttons["Work"].tap()
    XCTAssertTrue(app.staticTexts["Workspaces ServiceNow"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["CSM e CRM bancário"].exists)
  }

  func testCatalogComposerCanOrchestrateAFlow() {
    let app = XCUIApplication()
    app.launchArguments = ["-BankAppResetBrandSelection", "-BankAppSkipBrandSelection"]
    app.launch()

    XCTAssertTrue(app.staticTexts["NowOS Command Center"].waitForExistence(timeout: 8))
    app.tabBars.buttons["Catálogo"].tap()

    let requestField = app.textFields["Descreva a intenção ou problema"]
    XCTAssertTrue(requestField.waitForExistence(timeout: 5))
    requestField.tap()
    requestField.typeText("Cliente reportou falha no Pix com impacto CSM")

    let impactField = app.textFields["Cliente, serviço, área ou impacto"]
    impactField.tap()
    impactField.typeText("CSM, ITSM e risco operacional")

    let orchestrateButton = app.buttons["Orquestrar fluxo"]
    XCTAssertTrue(orchestrateButton.isEnabled)
    if orchestrateButton.isHittable == false {
      app.swipeUp()
    }
    orchestrateButton.tap()

    XCTAssertTrue(requestField.waitForExistence(timeout: 5))
    XCTAssertEqual(requestField.value as? String, "Descreva a intenção ou problema")
  }
}
