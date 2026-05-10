import Foundation

enum AppRoute: String, Equatable {
  case home
  case payments
  case security
  case support
  case profile
  case now
}

struct DeepLinkPayload: Codable, Equatable {
  let subjectCustomerId: String
  let journeyId: String
  let step: String
  let signedPayload: String
  let issuedAt: Date
  let expiresAt: Date
}

protocol DeepLinkValidating {
  func validate(_ payload: DeepLinkPayload) async throws -> Bool
}

struct DeepLinkRouter {
  private let telemetry: TelemetryTracking

  init(telemetry: TelemetryTracking = TelemetryClient.shared) {
    self.telemetry = telemetry
  }

  func route(for url: URL) -> AppRoute? {
    let route = resolveRoute(for: url)
    if let route {
      telemetry.track(
        .deepLinkReceived(
          sourceApp: url.scheme ?? "unknown",
          targetRoute: route.rawValue,
          signedPayloadValid: url.query?.contains("signed_payload=") ?? false
        )
      )
    }
    return route
  }

  private func resolveRoute(for url: URL) -> AppRoute? {
    let path = ([url.host] + url.pathComponents)
      .compactMap { $0 }
      .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "/")) }
      .filter { $0.isEmpty == false }
      .map { $0.lowercased() }

    if path.contains("pix") || path.contains("payments") || path.contains("pagamentos") {
      return .payments
    }
    if path.contains("security") || path.contains("seguranca") {
      return .security
    }
    if path.contains("support") || path.contains("atendimento") || path.contains("thread") {
      return .support
    }
    if path.contains("now") || path.contains("itsm") || path.contains("spm") {
      return .now
    }
    if path.contains("profile") || path.contains("perfil") {
      return .profile
    }
    if path.contains("home") || path.contains("app") {
      return .home
    }
    return nil
  }
}
