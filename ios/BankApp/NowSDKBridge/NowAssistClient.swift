import Foundation

struct NowAssistMessage: Identifiable, Equatable {
  enum Role: Equatable {
    case user
    case assistant
    case manager
  }

  let id: UUID
  let role: Role
  let text: String
  let timestamp: Date

  static var welcome: NowAssistMessage {
    let incident: String
    if AppBrand.current == .itau {
      incident = "P0 no Core Pix Personnalité"
    } else {
      incident = "P1 de latência Pix Prime"
    }

    return NowAssistMessage(
      id: UUID(uuidString: "BDE8CDB2-52BE-4DDE-9F9E-5F75F8CC4001")!,
      role: .assistant,
      text: "Oi, sou seu mordomo Otto / Now Assist no tenant \(AppBrand.current.displayName). "
        + "Já li o \(incident), CMDB Health, ITSM, SPM, CSM, CRM, aprovações e evidências. "
        + "Posso montar um workflow agentic, acionar AI specialists com guardrails e deixar "
        + "tudo auditável na instância.",
      timestamp: Date()
    )
  }

  static var initialMessages: [NowAssistMessage] {
    if ProcessInfo.processInfo.arguments.contains("-BankAppDemoConversation") {
      return demoConversation
    }

    return [.welcome]
  }

  static var demoConversation: [NowAssistMessage] {
    let brand = AppBrand.current
    let userText: String
    let assistantText: String

    if brand == .itau {
      userText = "Mordomo, resumo meu dia e o P0 do Itaú com workflow autônomo."
      assistantText =
        "Seu dia tem P0 no Core Pix, CMDB Health 91, CAB emergencial CHG004102, "
        + "CSM preventivo para Personnalité e SPM pronto para priorizar o fix estrutural. "
        + "Montei um run Autonomous Workforce: AIOps correlaciona eventos, Service Desk classifica, "
        + "CRM Case Management prepara o case e AI Control Tower segura a execução até sua aprovação."
    } else {
      userText = "Mordomo, resumo meu dia e o P1 do Bradesco com workflow autônomo."
      assistantText =
        "Seu dia tem P1 de latência Pix, CMDB Health 91, 42 cases Prime em risco, "
        + "mudança mobile pendente e CAB digital preparado. Posso assumir a war room, "
        + "acionar AIOps, abrir case CSM, preparar playbook de agência e expor o run auditável na instância."
    }

    return [
      .welcome,
      NowAssistMessage(
        id: UUID(uuidString: "BDE8CDB2-52BE-4DDE-9F9E-5F75F8CC4002")!,
        role: .user,
        text: userText,
        timestamp: Date()
      ),
      NowAssistMessage(
        id: UUID(uuidString: "BDE8CDB2-52BE-4DDE-9F9E-5F75F8CC4003")!,
        role: .assistant,
        text: assistantText,
        timestamp: Date()
      ),
    ]
  }
}

final class NowAssistClient {
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

  func send(_ text: String) async -> NowAssistMessage {
    telemetry.track(.nowSDKEvent(name: "chat.message.sent"))

    if let response = try? await sendToInstance(text, brand: .current) {
      telemetry.track(.nowSDKEvent(name: "chat.message.instance_reply"))
      return NowAssistMessage(
        id: UUID(), role: .assistant, text: response.message, timestamp: Date())
    }

    telemetry.track(.nowSDKEvent(name: "chat.message.local_fallback"))
    try? await Task.sleep(nanoseconds: 350_000_000)
    let response = MobileAssistResponse.demo(for: text)
    return NowAssistMessage(id: UUID(), role: .assistant, text: response.message, timestamp: Date())
  }

  private func sendToInstance(_ text: String, brand: AppBrand) async throws -> MobileAssistResponse
  {
    guard let baseURL else {
      throw ServiceNowClientError.invalidBaseURL
    }

    var components = URLComponents(
      url: baseURL.appendingPathComponent("/api/x_bank/v1/mobile-assist"),
      resolvingAgainstBaseURL: false
    )
    components?.queryItems = [URLQueryItem(name: "brand", value: brand.rawValue)]
    guard let url = components?.url else {
      throw ServiceNowClientError.invalidBaseURL
    }

    let body = MobileAssistRequest(
      message: text,
      brand: brand.rawValue,
      sessionId: UUID().uuidString,
      timezone: TimeZone.current.identifier
    )

    let started = Date()
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(AppEnvironment.marketingVersion, forHTTPHeaderField: "X-Client-Version")
    request.setValue("2026-05-assist-v1", forHTTPHeaderField: "X-Client-Schema-Version")
    request.setValue("ios", forHTTPHeaderField: "X-Client-Platform")
    request.httpBody = try JSONEncoder().encode(body)

    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw ServiceNowClientError.invalidResponse
    }

    let latency = Date().timeIntervalSince(started) * 1000
    telemetry.track(
      .apiCall(
        endpoint: "mobile-assist",
        version: "v1",
        latency: latency,
        status: httpResponse.statusCode
      )
    )

    guard (200..<300).contains(httpResponse.statusCode) else {
      throw ServiceNowClientError.httpStatus(httpResponse.statusCode)
    }

    return try JSONDecoder().decode(MobileAssistResponse.self, from: data)
  }

}
