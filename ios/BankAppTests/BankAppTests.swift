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
        "show_balance_by_default": false
      }
      """.utf8
    )

    let flags = try JSONDecoder().decode(FeatureFlags.self, from: data)

    XCTAssertTrue(flags.showCardVirtual)
    XCTAssertTrue(flags.enablePixShortcut)
    XCTAssertFalse(flags.enableConsentCenter)
    XCTAssertTrue(flags.isEnabled("enable_now_assist_chat"))
    XCTAssertFalse(flags.isEnabled("unknown_flag"))
  }

  func testMobileHomeResponseRoundTrip() throws {
    let encoded = try JSONEncoder().encode(MobileHomeResponse.demo)
    let decoded = try JSONDecoder().decode(MobileHomeResponse.self, from: encoded)

    XCTAssertEqual(decoded, .demo)
    XCTAssertEqual(decoded.schemaVersion, "2026-05-home-v1")
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
