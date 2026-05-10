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
  private let telemetry: TelemetryTracking

  init(telemetry: TelemetryTracking = TelemetryClient.shared) {
    self.telemetry = telemetry
  }

  func send(_ text: String) async -> NowAssistMessage {
    telemetry.track(.nowSDKEvent(name: "chat.message.sent"))
    try? await Task.sleep(nanoseconds: 350_000_000)

    let reply: String
    if text.localizedCaseInsensitiveContains("p0") {
      reply =
        "P0 priorizado: core Pix degradado para cohort crítico. CMDB mostra dependência entre app, gateway, antifraude e mensageria. Já montei o run agentic: AIOps RCA, Service Desk triagem, CRM Case Management CSM e AI Control Tower segurando a mudança até aprovação humana."
    } else if text.localizedCaseInsensitiveContains("p1") {
      reply =
        "P1 priorizado: latência Pix com impacto Prime. Relacionei incidente, cases CSM, CIs stale, rollback e plano de contenção. O autonomous workflow pode abrir ponte, gerar rascunho de comunicação e preparar change sem executar nada sensível sem sua aprovação."
    } else if text.localizedCaseInsensitiveContains("autonom")
      || text.localizedCaseInsensitiveContains("agentic")
      || text.localizedCaseInsensitiveContains("workflow")
      || text.localizedCaseInsensitiveContains("especialist")
    {
      reply =
        "Workflow agentic pronto: Sense com AIOps, Decide com L1 Service Desk AI Specialist, Act com CRM Case Management AI Specialist e Govern com AI Control Tower. Guardrails ativos: least privilege, prompt-shield, sem log de PII, citações KB/CMDB/CAB e trilha x_bank_ai_audit_event."
    } else if text.localizedCaseInsensitiveContains("action fabric")
      || text.localizedCaseInsensitiveContains("mcp")
      || text.localizedCaseInsensitiveContains("tool")
      || text.localizedCaseInsensitiveContains("fabric")
    {
      reply =
        "Action Fabric está expondo tools ServiceNow com política: abrir ponte, aprovar guardrail CAB, criar draft CSM e planejar remediação CMDB. Workflow Data Fabric entrega contexto sem copiar dados, e AI Control Tower mede risco, escopo e auditoria antes da execução."
    } else if text.localizedCaseInsensitiveContains("cmdb") {
      reply =
        "CMDB Health está em 91: completeness 92%, correctness 88%, compliance 95% e relações 84%. Recomendo corrigir CIs stale antes do próximo change."
    } else if text.localizedCaseInsensitiveContains("dia")
      || text.localizedCaseInsensitiveContains("mordomo")
    {
      reply =
        "Seu dia: 1 incidente crítico, 2 aprovações, CMDB com relações órfãs, 3 cases CSM em risco, 1 pedido executivo no catálogo, uma demanda SPM e um workflow autônomo aguardando sua aprovação."
    } else if text.localizedCaseInsensitiveContains("pix") {
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
