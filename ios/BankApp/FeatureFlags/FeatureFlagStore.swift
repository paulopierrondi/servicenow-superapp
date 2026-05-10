import Combine
import Foundation

@MainActor
final class FeatureFlagStore: ObservableObject {
  @Published private(set) var flags: FeatureFlags

  private let telemetry: TelemetryTracking

  init(flags: FeatureFlags = .demo, telemetry: TelemetryTracking = TelemetryClient.shared) {
    self.flags = flags
    self.telemetry = telemetry
  }

  func update(_ flags: FeatureFlags) {
    self.flags = flags
  }

  func isEnabled(_ key: String) -> Bool {
    let value = flags.isEnabled(key)
    telemetry.track(.featureFlagEvaluated(key: key, value: value, source: "server"))
    return value
  }
}
