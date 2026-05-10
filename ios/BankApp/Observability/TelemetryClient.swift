import Foundation
import OSLog

protocol TelemetryTracking {
  func track(_ event: TelemetryEvent)
}

enum TelemetryEvent: Equatable {
  case authSuccess(method: String)
  case authFailure(method: String, reason: String)
  case authStepUpSuccess
  case authStepUpFailure
  case apiCall(endpoint: String, version: String, latency: TimeInterval, status: Int)
  case featureFlagEvaluated(key: String, value: Bool, source: String)
  case deepLinkReceived(sourceApp: String, targetRoute: String, signedPayloadValid: Bool)
  case nowSDKEvent(name: String)

  var name: String {
    switch self {
    case .authSuccess: return "auth.success"
    case .authFailure: return "auth.failure"
    case .authStepUpSuccess: return "auth.step_up.success"
    case .authStepUpFailure: return "auth.step_up.failure"
    case .apiCall: return "api.call"
    case .featureFlagEvaluated: return "feature_flag.evaluated"
    case .deepLinkReceived: return "deep_link.received"
    case .nowSDKEvent: return "now_sdk.event"
    }
  }
}

final class TelemetryClient: TelemetryTracking {
  static let shared = TelemetryClient()

  private let logger = Logger(subsystem: "com.bradesco.mobile.app", category: "telemetry")

  func track(_ event: TelemetryEvent) {
    switch event {
    case .authSuccess(let method):
      logger.info("\(event.name, privacy: .public) method=\(method, privacy: .public)")
    case .authFailure(let method, let reason):
      logger.warning(
        "\(event.name, privacy: .public) method=\(method, privacy: .public) reason=\(reason, privacy: .public)"
      )
    case .authStepUpSuccess, .authStepUpFailure:
      logger.info("\(event.name, privacy: .public)")
    case .apiCall(let endpoint, let version, let latency, let status):
      logger.info(
        "\(event.name, privacy: .public) endpoint=\(endpoint, privacy: .public) version=\(version, privacy: .public) latency_ms=\(latency, privacy: .public) status=\(status, privacy: .public)"
      )
    case .featureFlagEvaluated(let key, let value, let source):
      logger.info(
        "\(event.name, privacy: .public) flag_key=\(key, privacy: .public) value=\(value, privacy: .public) source=\(source, privacy: .public)"
      )
    case .deepLinkReceived(let sourceApp, let targetRoute, let signedPayloadValid):
      logger.info(
        "\(event.name, privacy: .public) source_app=\(sourceApp, privacy: .public) target_route=\(targetRoute, privacy: .public) signed_payload_valid=\(signedPayloadValid, privacy: .public)"
      )
    case .nowSDKEvent(let name):
      logger.info("\(event.name, privacy: .public) name=\(name, privacy: .public)")
    }
  }
}
