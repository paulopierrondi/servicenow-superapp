import Foundation
import SwiftUI

@MainActor
final class AuthSession: ObservableObject {
  @Published private(set) var user: BankUser
  @Published var isBalanceVisible: Bool
  @Published var biometricEnabled: Bool
  @Published var trustedDeviceEnabled: Bool

  private let biometricGate: BiometricGate
  private let telemetry: TelemetryTracking

  init(
    user: BankUser = .demo,
    isBalanceVisible: Bool = FeatureFlags.demo.showBalanceByDefault,
    biometricEnabled: Bool = true,
    trustedDeviceEnabled: Bool = true,
    biometricGate: BiometricGate = BiometricGate(),
    telemetry: TelemetryTracking = TelemetryClient.shared
  ) {
    self.user = user
    self.isBalanceVisible = isBalanceVisible
    self.biometricEnabled = biometricEnabled
    self.trustedDeviceEnabled = trustedDeviceEnabled
    self.biometricGate = biometricGate
    self.telemetry = telemetry
    self.telemetry.track(.authSuccess(method: "demo_session"))
  }

  func toggleBalanceVisibility() async {
    if isBalanceVisible {
      withAnimation(.easeInOut) {
        isBalanceVisible = false
      }
      return
    }

    guard biometricEnabled else {
      withAnimation(.easeInOut) {
        isBalanceVisible = true
      }
      return
    }

    let allowed = await biometricGate.authenticate(reason: "auth.biometric.balance.reason")
    if allowed {
      telemetry.track(.authStepUpSuccess)
      withAnimation(.easeInOut) {
        isBalanceVisible = true
      }
    } else {
      telemetry.track(.authStepUpFailure)
    }
  }
}
