import Foundation

struct MobileHomeResponse: Codable, Equatable {
  let schemaVersion: String
  let featureFlags: FeatureFlags
  let cards: [HomeCardDTO]
  let compatibility: CompatibilityDTO

  static let demo = MobileHomeResponse(
    schemaVersion: "2026-05-home-v1",
    featureFlags: .demo,
    cards: HomeCardDTO.demo,
    compatibility: CompatibilityDTO(
      minClientVersion: "0.1.0",
      receivedClientVersion: "0.1.0",
      receivedSchemaHeader: "2026-05-home-v1",
      receivedPlatform: "ios"
    )
  )
}

struct FeatureFlags: Codable, Equatable {
  var showCardVirtual: Bool
  var enablePixShortcut: Bool
  var enableConsentCenter: Bool
  var enableNowAssistChat: Bool
  var showBalanceByDefault: Bool

  static let demo = FeatureFlags(
    showCardVirtual: true,
    enablePixShortcut: true,
    enableConsentCenter: true,
    enableNowAssistChat: true,
    showBalanceByDefault: false
  )

  enum CodingKeys: String, CodingKey {
    case showCardVirtual = "show_card_virtual"
    case enablePixShortcut = "enable_pix_shortcut"
    case enableConsentCenter = "enable_consent_center"
    case enableNowAssistChat = "enable_now_assist_chat"
    case showBalanceByDefault = "show_balance_by_default"
  }

  func isEnabled(_ key: String?) -> Bool {
    switch key {
    case "show_card_virtual": return showCardVirtual
    case "enable_pix_shortcut": return enablePixShortcut
    case "enable_consent_center": return enableConsentCenter
    case "enable_now_assist_chat": return enableNowAssistChat
    case "show_balance_by_default": return showBalanceByDefault
    case .none: return true
    default: return false
    }
  }
}

struct HomeCardDTO: Codable, Equatable, Identifiable {
  let id: String
  let title: String
  let subtitle: String
  let action: String
  let masked: Bool?
  let requiresFlag: String?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case subtitle
    case action
    case masked
    case requiresFlag = "requires_flag"
  }

  static let demo = [
    HomeCardDTO(
      id: "balance",
      title: "Conta principal",
      subtitle: "Saldo protegido",
      action: "open_balance",
      masked: true,
      requiresFlag: nil
    ),
    HomeCardDTO(
      id: "payments",
      title: "Pagamentos",
      subtitle: "Pix, boleto e cartão",
      action: "open_payments",
      masked: nil,
      requiresFlag: nil
    ),
    HomeCardDTO(
      id: "investments",
      title: "Investimentos",
      subtitle: "Carteira e objetivos",
      action: "open_investments",
      masked: nil,
      requiresFlag: nil
    ),
    HomeCardDTO(
      id: "support",
      title: "Atendimento",
      subtitle: "NowAssist com contexto",
      action: "open_support",
      masked: nil,
      requiresFlag: "enable_now_assist_chat"
    ),
  ]
}

struct CompatibilityDTO: Codable, Equatable {
  let minClientVersion: String
  let receivedClientVersion: String
  let receivedSchemaHeader: String
  let receivedPlatform: String
}

struct BankUser: Equatable {
  let firstName: String
  let segment: String
  let relationshipManager: String

  static var demo: BankUser {
    let brand = AppBrand.current
    return BankUser(
      firstName: "Paulo",
      segment: brand.customerSegment,
      relationshipManager: brand.relationshipManager
    )
  }
}

struct AccountSnapshot: Equatable {
  let availableBalance: Decimal
  let monthlyIncome: Decimal
  let monthlyOutcome: Decimal
  let creditLimit: Decimal
  let investmentBalance: Decimal
  let safetyScore: Int

  static let demo = AccountSnapshot(
    availableBalance: 8240.42,
    monthlyIncome: 18420.00,
    monthlyOutcome: 9128.76,
    creditLimit: 32500.00,
    investmentBalance: 128905.17,
    safetyScore: 94
  )
}

struct TransactionItem: Identifiable, Equatable {
  let id: UUID
  let merchant: String
  let category: String
  let amount: Decimal
  let isIncoming: Bool
  let symbolName: String

  static let demo = [
    TransactionItem(
      id: UUID(uuidString: "5E9C8FB5-876A-48EF-B09C-B03822EF4001")!,
      merchant: "Pix recebido",
      category: "Conta corrente",
      amount: 1250.00,
      isIncoming: true,
      symbolName: "arrow.down.left.circle.fill"
    ),
    TransactionItem(
      id: UUID(uuidString: "5E9C8FB5-876A-48EF-B09C-B03822EF4002")!,
      merchant: "Cartão final 4421",
      category: "Compra aprovada",
      amount: 318.90,
      isIncoming: false,
      symbolName: "creditcard.fill"
    ),
    TransactionItem(
      id: UUID(uuidString: "5E9C8FB5-876A-48EF-B09C-B03822EF4003")!,
      merchant: "Objetivo reserva",
      category: "Investimento automático",
      amount: 700.00,
      isIncoming: false,
      symbolName: "chart.line.uptrend.xyaxis.circle.fill"
    ),
  ]
}

struct SmartInsight: Identifiable, Equatable {
  let id: UUID
  let title: String
  let detail: String
  let symbolName: String

  static let demo = [
    SmartInsight(
      id: UUID(uuidString: "F5760E6C-B5C7-4B27-A604-A6E5C225B001")!,
      title: "Pix recorrente pronto",
      detail: "O aluguel vence amanhã. Agende com biometria e recibo automático.",
      symbolName: "bolt.horizontal.circle.fill"
    ),
    SmartInsight(
      id: UUID(uuidString: "F5760E6C-B5C7-4B27-A604-A6E5C225B002")!,
      title: "Open Finance ativo",
      detail: "Seu limite foi recalculado com dados compartilhados até junho.",
      symbolName: "link.circle.fill"
    ),
  ]
}

enum NowWorkDomain: String, Codable, Equatable {
  case itsm
  case spm
}

struct NowWorkItem: Identifiable, Codable, Equatable {
  let id: String
  let domain: NowWorkDomain
  let category: String
  let title: String
  let summary: String
  let owner: String
  let status: String
  let priority: String
  let due: String
  let signal: String

  static let demoITSM = [
    NowWorkItem(
      id: "INC0012487",
      domain: .itsm,
      category: "Incidente",
      title: "Alta latência no Pix",
      summary: "Correlação entre gateway mobile, provedor antifraude e filas de callback.",
      owner: "SRE Mobile",
      status: "Em contenção",
      priority: "P1",
      due: "SLA 18 min",
      signal: "Now Assist preparou causa provável e próximos passos"
    ),
    NowWorkItem(
      id: "RITM009812",
      domain: .itsm,
      category: "Requisição",
      title: "Cartão virtual corporativo",
      summary: "Solicitação aprovada aguardando emissão com validação de perfil.",
      owner: "Operações cartões",
      status: "Aguardando automação",
      priority: "P3",
      due: "Hoje",
      signal: "Pronto para fulfill via Flow Designer"
    ),
    NowWorkItem(
      id: "CHG004102",
      domain: .itsm,
      category: "Mudança",
      title: "Janela mobile backend",
      summary: "Troca progressiva de feature flags com rollback por cohort.",
      owner: "CAB Digital",
      status: "Aprovada",
      priority: "P2",
      due: "12 mai",
      signal: "Risco baixo, plano de reversão validado"
    ),
  ]

  static let demoSPM = [
    NowWorkItem(
      id: "DMND000731",
      domain: .spm,
      category: "Demanda",
      title: "Consent hub Open Finance",
      summary: "Business case une LGPD, jornadas de consentimento e analytics opt-in.",
      owner: "Portfólio digital",
      status: "Priorizada",
      priority: "Valor alto",
      due: "Q2",
      signal: "Now Assist resumiu dependências e benefícios esperados"
    ),
    NowWorkItem(
      id: "PRJ001927",
      domain: .spm,
      category: "Projeto",
      title: "ZTA Mobile",
      summary: "Roadmap de autenticação contínua, device trust e observabilidade.",
      owner: "Cyber + Canais",
      status: "Verde",
      priority: "Estratégico",
      due: "72%",
      signal: "Desvio de prazo dentro da tolerância"
    ),
    NowWorkItem(
      id: "RISK000442",
      domain: .spm,
      category: "Risco",
      title: "Residência de dados Railway",
      summary: "Avaliação de ambientes auxiliares antes de qualquer payload produtivo.",
      owner: "GRC",
      status: "Mitigando",
      priority: "Regulatório",
      due: "16 mai",
      signal: "Controle exige revisão jurídica antes de produção"
    ),
  ]
}

struct NowLauncherItem: Identifiable, Equatable {
  let id: String
  let title: String
  let subtitle: String
  let department: String
  let symbolName: String
  let tint: NowWorkDomain?

  static let demo = [
    NowLauncherItem(
      id: "it-laptop",
      title: "Solicitar notebook",
      subtitle: "TI • Catálogo com aprovação",
      department: "TI",
      symbolName: "laptopcomputer",
      tint: .itsm
    ),
    NowLauncherItem(
      id: "facilities-room",
      title: "Reservar sala segura",
      subtitle: "Facilities • Reserva com QR",
      department: "Facilities",
      symbolName: "building.2.crop.circle.fill",
      tint: .itsm
    ),
    NowLauncherItem(
      id: "finance-card",
      title: "Cartão corporativo",
      subtitle: "Financeiro • Solicitação",
      department: "Financeiro",
      symbolName: "creditcard.fill",
      tint: .spm
    ),
    NowLauncherItem(
      id: "legal-nda",
      title: "NDA fornecedor",
      subtitle: "Jurídico • Fluxo assinado",
      department: "Jurídico",
      symbolName: "doc.text.fill",
      tint: .spm
    ),
    NowLauncherItem(
      id: "hr-profile",
      title: "Atualizar perfil",
      subtitle: "RH • Dados e férias",
      department: "RH",
      symbolName: "person.text.rectangle.fill",
      tint: nil
    ),
  ]
}

struct NowActionItem: Identifiable, Equatable {
  let id: String
  let title: String
  let requester: String
  let detail: String
  let due: String
  let actionLabel: String
  let riskLevel: String

  static let demo = [
    NowActionItem(
      id: "APR000812",
      title: "Aprovar mudança mobile",
      requester: "CAB Digital",
      detail: "Janela para novo backend de feature flags com rollback por cohort.",
      due: "Hoje 17:00",
      actionLabel: "Aprovar",
      riskLevel: "Médio"
    ),
    NowActionItem(
      id: "TASK004219",
      title: "Revisar evidência LGPD",
      requester: "GRC",
      detail: "Confirmação de base legal antes de habilitar analytics opt-in.",
      due: "Amanhã",
      actionLabel: "Revisar",
      riskLevel: "Alto"
    ),
  ]
}

struct NowKnowledgeAnswer: Identifiable, Equatable {
  let id: String
  let question: String
  let answer: String
  let citation: String

  static let demo = NowKnowledgeAnswer(
    id: "kb-open-finance",
    question: "Como revisar consentimento Open Finance?",
    answer:
      "Abra Segurança, confira compartilhamentos ativos e registre qualquer alteração como caso auditável no ServiceNow.",
    citation: "KB001928 • Política digital"
  )
}

enum CustomerExperienceDomain: String, Equatable {
  case csm
  case crm
}

struct CustomerExperienceItem: Identifiable, Equatable {
  let id: String
  let domain: CustomerExperienceDomain
  let title: String
  let detail: String
  let metric: String
  let owner: String
  let symbolName: String

  static func bankingDemo(for brand: AppBrand = .current) -> [CustomerExperienceItem] {
    let segment = brand.customerSegment
    let manager = brand.relationshipManager
    let crmTitle = brand == .itau ? "Next best action Personnalité" : "Next best action Prime"
    let relationshipTitle =
      brand == .itau ? "Relacionamento Itaú 360" : "Relacionamento Bradesco 360"
    let relationshipDetail =
      brand == .itau
      ? "Perfil, momento de vida, cartões, íon e atendimento priorizados em uma visão CRM."
      : "Carteira, cartões, seguros, investimentos e atendimento priorizados em uma visão CRM."

    return [
      CustomerExperienceItem(
        id: "csm-pix-case",
        domain: .csm,
        title: "Caso Pix contestado",
        detail: "Case CSM com SLA, histórico omnicanal e evidências do gêmeo operacional.",
        metric: "SLA 18 min",
        owner: "CSM",
        symbolName: "person.crop.circle.badge.exclamationmark.fill"
      ),
      CustomerExperienceItem(
        id: "csm-manager-handoff",
        domain: .csm,
        title: "Handoff para gerente",
        detail: "Now Assist preserva contexto, consentimento e próximos passos para \(manager).",
        metric: "1 thread",
        owner: segment,
        symbolName: "person.text.rectangle.fill"
      ),
      CustomerExperienceItem(
        id: "csm-voice-of-customer",
        domain: .csm,
        title: "Voz do cliente",
        detail: "Reclamação, NPS, causa raiz e incidente conectados antes da resposta final.",
        metric: "NPS +12",
        owner: "CX",
        symbolName: "waveform"
      ),
      CustomerExperienceItem(
        id: "crm-next-best-action",
        domain: .crm,
        title: crmTitle,
        detail:
          "Oferta explicável com consentimento, propensão, elegibilidade e limite operacional.",
        metric: "NBA",
        owner: "CRM",
        symbolName: "sparkles"
      ),
      CustomerExperienceItem(
        id: "crm-relationship-360",
        domain: .crm,
        title: relationshipTitle,
        detail: relationshipDetail,
        metric: "360",
        owner: brand.displayName,
        symbolName: "circle.grid.cross.fill"
      ),
    ]
  }
}

struct NowJourneyTwin: Equatable {
  let title: String
  let hypothesis: String
  let minutesSaved: String
  let riskDelta: String
  let auditId: String
  let nodes: [NowJourneyNode]
  let pulses: [NowJourneyPulse]

  static var demo: NowJourneyTwin {
    NowJourneyTwin(
      title: "Pix contestado sem abrir chamado manual",
      hypothesis:
        "O app calcula o impacto antes de executar: cliente, consentimento, antifraude, ITSM, SPM e auditoria ficam no mesmo mapa.",
      minutesSaved: "42 min",
      riskDelta: "-31%",
      auditId: "JTW-2026-0510",
      nodes: [
        NowJourneyNode(
          id: "customer",
          title: "Cliente",
          subtitle: "Intenção capturada",
          symbolName: "person.crop.circle.fill",
          owner: AppBrand.current.displayName,
          confidence: 0.98,
          isCritical: false
        ),
        NowJourneyNode(
          id: "consent",
          title: "Consentimento",
          subtitle: "Base legal checada",
          symbolName: "hand.raised.fill",
          owner: "LGPD",
          confidence: 0.91,
          isCritical: false
        ),
        NowJourneyNode(
          id: "risk",
          title: "Risco",
          subtitle: "Score recalculado",
          symbolName: "shield.lefthalf.filled",
          owner: "ZTA",
          confidence: 0.87,
          isCritical: true
        ),
        NowJourneyNode(
          id: "assist",
          title: "Now Assist",
          subtitle: "Resumo e próximos passos",
          symbolName: "sparkles",
          owner: "AI",
          confidence: 0.94,
          isCritical: false
        ),
        NowJourneyNode(
          id: "itsm",
          title: "ITSM",
          subtitle: "Incidente correlacionado",
          symbolName: "wrench.and.screwdriver.fill",
          owner: "SRE",
          confidence: 0.83,
          isCritical: true
        ),
        NowJourneyNode(
          id: "spm",
          title: "SPM",
          subtitle: "Demanda conectada",
          symbolName: "chart.line.uptrend.xyaxis",
          owner: "Portfólio",
          confidence: 0.79,
          isCritical: false
        ),
        NowJourneyNode(
          id: "audit",
          title: "Auditoria",
          subtitle: "Trilha imutável",
          symbolName: "lock.doc.fill",
          owner: "GRC",
          confidence: 1,
          isCritical: false
        ),
      ],
      pulses: [
        NowJourneyPulse(
          id: "client",
          title: "Impacto cliente",
          metric: "1 toque",
          detail: "Sem descobrir qual área resolve",
          symbolName: "hand.tap.fill"
        ),
        NowJourneyPulse(
          id: "operation",
          title: "Impacto operação",
          metric: "6 áreas",
          detail: "Orquestradas por contrato único",
          symbolName: "point.3.connected.trianglepath.dotted"
        ),
        NowJourneyPulse(
          id: "audit",
          title: "Impacto compliance",
          metric: "100%",
          detail: "Contexto pronto para revisão",
          symbolName: "checkmark.seal.fill"
        ),
      ]
    )
  }
}

struct NowJourneyNode: Identifiable, Equatable {
  let id: String
  let title: String
  let subtitle: String
  let symbolName: String
  let owner: String
  let confidence: Double
  let isCritical: Bool
}

struct NowJourneyPulse: Identifiable, Equatable {
  let id: String
  let title: String
  let metric: String
  let detail: String
  let symbolName: String
}

struct ScheduledPayment: Identifiable, Equatable {
  let id: UUID
  let title: String
  let dueDate: String
  let amount: Decimal
  let status: String

  static let demo = [
    ScheduledPayment(
      id: UUID(uuidString: "AB62FF2F-A984-492B-B7C1-5D17A5BCA001")!,
      title: "Energia",
      dueDate: "12 mai",
      amount: 248.52,
      status: "Aguardando"
    ),
    ScheduledPayment(
      id: UUID(uuidString: "AB62FF2F-A984-492B-B7C1-5D17A5BCA002")!,
      title: "Condomínio",
      dueDate: "15 mai",
      amount: 1120.00,
      status: "Agendado"
    ),
  ]
}

enum MoneyFormatter {
  static let brl: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter
  }()

  static func string(from value: Decimal) -> String {
    brl.string(from: value as NSDecimalNumber) ?? "R$ 0,00"
  }

  static func compactString(from value: Decimal) -> String {
    let doubleValue = NSDecimalNumber(decimal: value).doubleValue

    if abs(doubleValue) >= 1_000_000 {
      return localizedCompact(value: doubleValue / 1_000_000, suffix: "mi")
    }

    if abs(doubleValue) >= 1_000 {
      return localizedCompact(value: doubleValue / 1_000, suffix: "k")
    }

    return string(from: value)
  }

  private static func localizedCompact(value: Double, suffix: String) -> String {
    let formatted = String(format: "R$ %.1f%@", locale: Locale(identifier: "pt_BR"), value, suffix)
    return formatted.replacingOccurrences(of: ".0", with: "")
  }
}
