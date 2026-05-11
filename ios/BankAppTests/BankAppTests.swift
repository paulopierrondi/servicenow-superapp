import XCTest

@testable import BankApp

final class BankAppTests: XCTestCase {
  func testFeatureFlagsDecodeServiceNowKeys() throws {
    let data = Data(
      """
      {
        "show_card_virtual": true,
        "enable_pix_shortcut": true,
        "enable_consent_center": false,
        "enable_now_assist_chat": true,
        "show_balance_by_default": false,
        "enable_autonomous_workforce": true
      }
      """.utf8
    )

    let flags = try JSONDecoder().decode(FeatureFlags.self, from: data)

    XCTAssertTrue(flags.showCardVirtual)
    XCTAssertTrue(flags.enablePixShortcut)
    XCTAssertFalse(flags.enableConsentCenter)
    XCTAssertTrue(flags.isEnabled("enable_now_assist_chat"))
    XCTAssertTrue(flags.isEnabled("enable_autonomous_workforce"))
    XCTAssertFalse(flags.isEnabled("unknown_flag"))
  }

  func testMobileHomeResponseRoundTrip() throws {
    let encoded = try JSONEncoder().encode(MobileHomeResponse.demo)
    let decoded = try JSONDecoder().decode(MobileHomeResponse.self, from: encoded)

    XCTAssertEqual(decoded, .demo)
    XCTAssertEqual(decoded.schemaVersion, "2026-05-home-v1")
  }

  func testMobileHomeDemoIsServiceNowFirst() {
    let actions = Set(MobileHomeResponse.demo.cards.map(\.action))

    XCTAssertTrue(actions.contains("open_workspaces"))
    XCTAssertTrue(actions.contains("open_catalog"))
    XCTAssertFalse(actions.contains("open_payments"))
    XCTAssertFalse(MobileHomeResponse.demo.cards.contains { $0.title == "Conta principal" })
  }

  func testDeepLinkRoutesCustomSchemeAndUniversalLink() throws {
    let router = DeepLinkRouter(telemetry: NoopTelemetry())

    let pixURL = try XCTUnwrap(URL(string: "bradesco-app://payments/pix"))
    let supportURL = try XCTUnwrap(
      URL(string: "https://m.bradesco.com.br/atendimento/thread/123?signed_payload=abc"))
    let itauNowURL = try XCTUnwrap(URL(string: "itau-app://now/itsm"))

    XCTAssertEqual(router.route(for: pixURL), .payments)
    XCTAssertEqual(router.route(for: supportURL), .support)
    XCTAssertEqual(router.route(for: itauNowURL), .now)
  }

  func testNowWorkItemsCoverITSMAndSPM() {
    XCTAssertTrue(NowWorkItem.demoITSM.contains { $0.category == "Incidente" })
    XCTAssertTrue(NowWorkItem.demoITSM.contains { $0.category == "Mudança" })
    XCTAssertTrue(NowWorkItem.demoSPM.contains { $0.category == "Demanda" })
    XCTAssertTrue(NowWorkItem.demoSPM.contains { $0.category == "Projeto" })
  }

  func testCriticalIncidentAdaptsToSelectedBank() {
    let previous = UserDefaults.standard.string(forKey: AppBrand.selectionDefaultsKey)
    defer {
      if let previous {
        UserDefaults.standard.set(previous, forKey: AppBrand.selectionDefaultsKey)
      } else {
        UserDefaults.standard.removeObject(forKey: AppBrand.selectionDefaultsKey)
      }
    }

    UserDefaults.standard.set(AppBrand.bradesco.rawValue, forKey: AppBrand.selectionDefaultsKey)
    XCTAssertTrue(
      NowWorkItem.demoITSM.contains { $0.priority == "P1" && $0.title.contains("Prime") }
    )

    UserDefaults.standard.set(AppBrand.itau.rawValue, forKey: AppBrand.selectionDefaultsKey)
    XCTAssertTrue(
      NowWorkItem.demoITSM.contains { $0.priority == "P0" && $0.title.contains("Personnalité") }
    )
  }

  func testBrandSelectionOverridesEnvironmentDefault() throws {
    let suiteName = "BrandSelectionTests-\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }

    defaults.set(AppBrand.itau.rawValue, forKey: AppBrand.selectionDefaultsKey)

    let brand = AppBrand.resolve(userDefaults: defaults, environment: ["APP_BRAND": "bradesco"])

    XCTAssertEqual(brand, .itau)
  }

  func testNowMobileEvolutionIncludesCrossDepartmentLauncherAndActions() {
    XCTAssertTrue(NowLauncherItem.demo.contains { $0.department == "TI" })
    XCTAssertTrue(NowLauncherItem.demo.contains { $0.department == "RH" })
    XCTAssertTrue(NowActionItem.demo.contains { $0.actionLabel == "Aprovar" })
    XCTAssertEqual(NowKnowledgeAnswer.demo.citation, "KB001928 • Política digital")
  }

  func testCustomerExperienceIncludesCSMAndCRMForBanking() {
    let bradescoItems = CustomerExperienceItem.bankingDemo(for: .bradesco)
    let itauItems = CustomerExperienceItem.bankingDemo(for: .itau)

    XCTAssertTrue(bradescoItems.contains { $0.domain == .csm && $0.title == "Caso Pix contestado" })
    XCTAssertTrue(bradescoItems.contains { $0.domain == .crm && $0.title.contains("Prime") })
    XCTAssertTrue(itauItems.contains { $0.domain == .crm && $0.title.contains("Personnalité") })
  }

  func testNowAssistWelcomeIsOperationalNotTransactional() {
    let message = NowAssistMessage.welcome.text

    XCTAssertTrue(message.contains("ITSM"))
    XCTAssertTrue(message.contains("CSM"))
    XCTAssertTrue(message.contains("CRM"))
    XCTAssertTrue(message.contains("workflow agentic"))
    XCTAssertFalse(message.contains("Saldo"))
  }

  func testNowAssistDemoConversationActsAsOperationalButler() {
    let messages = NowAssistMessage.demoConversation.map(\.text).joined(separator: " ")

    XCTAssertTrue(messages.contains("Mordomo"))
    XCTAssertTrue(messages.contains("CMDB Health"))
    XCTAssertTrue(messages.contains("SPM"))
    XCTAssertFalse(messages.contains("Saldo"))
  }

  func testJourneyTwinConnectsBankingIntentToOperationalControls() {
    let twin = NowJourneyTwin.demo

    XCTAssertEqual(twin.auditId, "JTW-2026-0510")
    XCTAssertEqual(twin.nodes.first?.id, "customer")
    XCTAssertTrue(twin.nodes.contains { $0.id == "itsm" && $0.isCritical })
    XCTAssertTrue(twin.nodes.contains { $0.id == "spm" })
    XCTAssertTrue(twin.pulses.contains { $0.id == "audit" })
  }

  func testAutonomousWorkflowIncludesGovernedAISpecialists() {
    let workflow = AutonomousWorkflowResponse.demo

    XCTAssertEqual(workflow.schemaVersion, "2026-05-agentic-v1")
    XCTAssertTrue(workflow.controlPlane.controlTower.contains("AI Control Tower"))
    XCTAssertTrue(workflow.agents.contains { $0.name.contains("AIOps") })
    XCTAssertTrue(workflow.agents.contains { $0.name.contains("CRM Case Management") })
    XCTAssertTrue(workflow.platformSignals.contains { $0.layer == "Action Fabric" })
    XCTAssertTrue(workflow.platformSignals.contains { $0.layer == "Workflow Data Fabric" })
    XCTAssertTrue(workflow.actionPackages.contains { $0.tool.contains("change.guardrail") })
    XCTAssertTrue(workflow.controlMetrics.contains { $0.title == "Policy pass" })
    XCTAssertTrue(workflow.run.steps.contains { $0.requiresHumanApproval })
    XCTAssertFalse(workflow.governance.piiLoggingAllowed)
    XCTAssertTrue(workflow.citations.contains { $0.label == "Service Graph" })
  }

  func testMobileAssistDemoResponseActsAsInstanceConcierge() {
    let response = MobileAssistResponse.demo(for: "mordomo, resumo meu dia e CMDB", brand: .itau)

    XCTAssertEqual(response.schemaVersion, "2026-05-assist-v1")
    XCTAssertEqual(response.brand, AppBrand.itau.rawValue)
    XCTAssertTrue(response.provider.nativeNowAssistPath.contains("Virtual Agent API"))
    XCTAssertTrue(response.message.contains("CMDB Health"))
    XCTAssertTrue(response.nextActions.contains { $0.id == "approve_guardrail" })
    XCTAssertTrue(response.citations.contains { $0.label == "Service Graph" })
  }

  @MainActor
  func testHomeViewModelFallsBackToDemoOnClientFailure() async {
    let viewModel = HomeViewModel(serviceNowClient: FailingHomeClient())

    await viewModel.load()

    XCTAssertEqual(viewModel.home, .demo)
    XCTAssertFalse(viewModel.isLoading)
  }
}

private struct FailingHomeClient: ServiceNowClienting {
  func fetchHome() async throws -> MobileHomeResponse {
    throw ServiceNowClientError.invalidBaseURL
  }
}

private struct NoopTelemetry: TelemetryTracking {
  func track(_ event: TelemetryEvent) {}
}
