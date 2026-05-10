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
    NowAssistMessage(
      id: UUID(uuidString: "BDE8CDB2-52BE-4DDE-9F9E-5F75F8CC4001")!,
      role: .assistant,
      text:
        "Oi, sou o NowAssist do tenant \(AppBrand.current.displayName). Posso analisar incidentes, cases, demandas, consentimentos, ITSM, SPM, CSM, CRM e acionar especialistas com contexto.",
      timestamp: Date()
    )
  }
}

final class NowAssistClient {
  private let telemetry: TelemetryTracking

  init(telemetry: TelemetryTracking = TelemetryClient.shared) {
    self.telemetry = telemetry
  }

  func send(_ text: String) async -> NowAssistMessage {
    telemetry.track(.nowSDKEvent(name: "chat.message.sent"))
    try? await Task.sleep(nanoseconds: 350_000_000)

    let reply: String
    if text.localizedCaseInsensitiveContains("pix") {
      reply =
        "Vou tratar Pix como jornada operacional: CSM para impacto ao cliente, ITSM para degradação, CRM para comunicação e SPM se virar demanda."
    } else if text.localizedCaseInsensitiveContains("itsm") {
      reply =
        "No ITSM, o incidente de latência Pix está em contenção. Já gerei resumo de causa provável, SLA e plano de comunicação."
    } else if text.localizedCaseInsensitiveContains("spm") {
      reply =
        "No SPM, a demanda de Open Finance está priorizada. Posso resumir valor, riscos regulatórios e dependências para o comitê."
    } else if text.localizedCaseInsensitiveContains("aprovar") {
      reply =
        "Encontrei aprovações pendentes. Posso resumir impacto, risco, SLA e evidências antes da decisão."
    } else if text.localizedCaseInsensitiveContains("gêmeo")
      || text.localizedCaseInsensitiveContains("gemeo")
      || text.localizedCaseInsensitiveContains("jornada")
    {
      reply =
        "Montei o gêmeo operacional: intenção do cliente, consentimento, risco, CSM, CRM, ITSM, SPM e auditoria ficam conectados antes da execução."
    } else if text.localizedCaseInsensitiveContains("notebook")
      || text.localizedCaseInsensitiveContains("sala")
    {
      reply =
        "Posso abrir o item de catálogo correto, preencher dados conhecidos e manter a solicitação rastreável na plataforma."
    } else if text.localizedCaseInsensitiveContains("cart") {
      reply =
        "Se envolver cartão, eu separo experiência do cliente, risco, evidência e fluxo operacional antes de qualquer ação transacional."
    } else {
      reply =
        "Vou cruzar os dados da sua conta com os fluxos ServiceNow e trazer uma resposta acionável. Nenhum dado sensível será exposto no chat."
    }

    return NowAssistMessage(id: UUID(), role: .assistant, text: reply, timestamp: Date())
  }
}
