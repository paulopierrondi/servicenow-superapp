import Foundation
import LocalAuthentication

struct BiometricGate {
  func authenticate(reason: String) async -> Bool {
    let context = LAContext()
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
      return true
    }

    let localizedReason = NSLocalizedString(reason, comment: "REVISÃO PT-BR HUMANA OBRIGATÓRIA")

    return await withCheckedContinuation { continuation in
      context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason
      ) { success, _ in
        continuation.resume(returning: success)
      }
    }
  }
}
