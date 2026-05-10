import Foundation

protocol ServiceNowClienting {
  func fetchHome() async throws -> MobileHomeResponse
}

enum ServiceNowClientError: Error, Equatable {
  case invalidBaseURL
  case invalidResponse
  case httpStatus(Int)
}

final class ServiceNowClient: ServiceNowClienting {
  private let session: URLSession
  private let baseURL: URL?
  private let telemetry: TelemetryTracking

  init(
    session: URLSession = .shared,
    baseURL: URL? = AppEnvironment.serviceNowInstanceURL,
    telemetry: TelemetryTracking = TelemetryClient.shared
  ) {
    self.session = session
    self.baseURL = baseURL
    self.telemetry = telemetry
  }

  func fetchHome() async throws -> MobileHomeResponse {
    guard let baseURL else {
      telemetry.track(.apiCall(endpoint: "mobile-home", version: "v1", latency: 0, status: 0))
      return .demo
    }

    let started = Date()
    var request = URLRequest(url: baseURL.appendingPathComponent("/api/x_bank/v1/mobile-home"))
    request.setValue(AppEnvironment.marketingVersion, forHTTPHeaderField: "X-Client-Version")
    request.setValue(
      MobileHomeResponse.demo.schemaVersion, forHTTPHeaderField: "X-Client-Schema-Version")
    request.setValue("ios", forHTTPHeaderField: "X-Client-Platform")

    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw ServiceNowClientError.invalidResponse
    }

    let latency = Date().timeIntervalSince(started) * 1000
    telemetry.track(
      .apiCall(
        endpoint: "mobile-home",
        version: "v1",
        latency: latency,
        status: httpResponse.statusCode
      )
    )

    guard (200..<300).contains(httpResponse.statusCode) else {
      throw ServiceNowClientError.httpStatus(httpResponse.statusCode)
    }

    return try JSONDecoder().decode(MobileHomeResponse.self, from: data)
  }
}

enum AppEnvironment {
  static var marketingVersion: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
  }

  static var serviceNowInstanceURL: URL? {
    guard
      let rawValue = Bundle.main.object(forInfoDictionaryKey: "SERVICENOW_INSTANCE_URL") as? String,
      rawValue.isEmpty == false
    else {
      return nil
    }
    return URL(string: rawValue)
  }
}
