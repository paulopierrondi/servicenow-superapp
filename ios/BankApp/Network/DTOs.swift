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
  var enableAutonomousWorkforce: Bool

  static let demo = FeatureFlags(
    showCardVirtual: true,
    enablePixShortcut: true,
    enableConsentCenter: true,
    enableNowAssistChat: true,
    showBalanceByDefault: false,
    enableAutonomousWorkforce: true
  )

  enum CodingKeys: String, CodingKey {
    case showCardVirtual = "show_card_virtual"
    case enablePixShortcut = "enable_pix_shortcut"
    case enableConsentCenter = "enable_consent_center"
    case enableNowAssistChat = "enable_now_assist_chat"
    case showBalanceByDefault = "show_balance_by_default"
    case enableAutonomousWorkforce = "enable_autonomous_workforce"
  }

  init(
    showCardVirtual: Bool,
    enablePixShortcut: Bool,
    enableConsentCenter: Bool,
    enableNowAssistChat: Bool,
    showBalanceByDefault: Bool,
    enableAutonomousWorkforce: Bool
  ) {
    self.showCardVirtual = showCardVirtual
    self.enablePixShortcut = enablePixShortcut
    self.enableConsentCenter = enableConsentCenter
    self.enableNowAssistChat = enableNowAssistChat
    self.showBalanceByDefault = showBalanceByDefault
    self.enableAutonomousWorkforce = enableAutonomousWorkforce
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    showCardVirtual =
      try container.decodeIfPresent(Bool.self, forKey: .showCardVirtual) ?? false
    enablePixShortcut =
      try container.decodeIfPresent(Bool.self, forKey: .enablePixShortcut) ?? false
    enableConsentCenter =
      try container.decodeIfPresent(Bool.self, forKey: .enableConsentCenter) ?? false
    enableNowAssistChat =
      try container.decodeIfPresent(Bool.self, forKey: .enableNowAssistChat) ?? false
    showBalanceByDefault =
      try container.decodeIfPresent(Bool.self, forKey: .showBalanceByDefault) ?? false
    enableAutonomousWorkforce =
      try container.decodeIfPresent(Bool.self, forKey: .enableAutonomousWorkforce) ?? false
  }

  func isEnabled(_ key: String?) -> Bool {
    switch key {
    case "show_card_virtual": return showCardVirtual
    case "enable_pix_shortcut": return enablePixShortcut
    case "enable_consent_center": return enableConsentCenter
    case "enable_now_assist_chat": return enableNowAssistChat
    case "show_balance_by_default": return showBalanceByDefault
    case "enable_autonomous_workforce": return enableAutonomousWorkforce
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
      id: "workspaces",
      title: "Workspaces",
      subtitle: "ITSM, SPM, CSM e CRM",
      action: "open_workspaces",
      masked: nil,
      requiresFlag: nil
    ),
    HomeCardDTO(
      id: "catalog",
      title: "Catálogo vivo",
      subtitle: "Orquestração por intenção",
      action: "open_catalog",
      masked: nil,
      requiresFlag: nil
    ),
    HomeCardDTO(
      id: "investments",
      title: "Trust",
      subtitle: "Consentimento e auditoria",
      action: "open_security",
      masked: nil,
      requiresFlag: nil
    ),
    HomeCardDTO(
      id: "assist",
      title: "Otto / Now Assist",
      subtitle: "AI agentic com contexto",
      action: "open_support",
      masked: nil,
      requiresFlag: "enable_now_assist_chat"
    ),
    HomeCardDTO(
      id: "autonomous",
      title: "Autonomous Workforce",
      subtitle: "AI specialists com governança",
      action: "open_agentic_workflow",
      masked: nil,
      requiresFlag: "enable_autonomous_workforce"
    ),
    HomeCardDTO(
      id: "action-fabric",
      title: "Action Fabric",
      subtitle: "Tools ServiceNow via MCP",
      action: "open_action_fabric",
      masked: nil,
      requiresFlag: "enable_autonomous_workforce"
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
      detail: "Now Assist detectou intenção repetida e recomenda catálogo com aprovação auditável.",
      symbolName: "bolt.horizontal.circle.fill"
    ),
    SmartInsight(
      id: UUID(uuidString: "F5760E6C-B5C7-4B27-A604-A6E5C225B002")!,
      title: "Consentimento com impacto",
      detail: "Mudança de compartilhamento deve gerar evidência LGPD e atualização no case.",
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

  static var demoITSM: [NowWorkItem] {
    let isItau = AppBrand.current == .itau

    return [
      NowWorkItem(
        id: isItau ? "INC-P0-ITAU-042" : "INC-P1-BRAD-2487",
        domain: .itsm,
        category: "Incidente",
        title: isItau ? "P0 Core Pix Personnalité" : "P1 Latência Pix Prime",
        summary: isItau
          ? "Indisponibilidade em cohort crítico conectada a gateway, antifraude e mensageria."
          : "Correlação entre gateway mobile, provedor antifraude e filas de callback.",
        owner: "SRE Mobile",
        status: isItau ? "War room ativa" : "Em contenção",
        priority: isItau ? "P0" : "P1",
        due: isItau ? "Agora" : "SLA 18 min",
        signal: isItau
          ? "Now Assist preparou briefing executivo, CMDB e próximos passos"
          : "Now Assist preparou causa provável e próximos passos"
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
  }

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
        "O app calcula o impacto antes de executar: cliente, consentimento, risco, CSM, CRM, ITSM, SPM e auditoria ficam no mesmo mapa.",
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

struct AutonomousWorkflowResponse: Codable, Equatable {
  let schemaVersion: String
  let brand: String
  let controlPlane: AutonomousControlPlane
  let run: AutonomousWorkflowRun
  let agents: [AutonomousAgent]
  let platformSignals: [PlatformFabricSignal]
  let actionPackages: [ActionFabricPackage]
  let controlMetrics: [AIControlMetric]
  let governance: AutonomousGovernance
  let citations: [AutonomousCitation]
  let compatibility: CompatibilityDTO

  static var demo: AutonomousWorkflowResponse {
    let brand = AppBrand.current
    return AutonomousWorkflowResponse(
      schemaVersion: "2026-05-agentic-v1",
      brand: brand.rawValue,
      controlPlane: .demo(for: brand),
      run: .demo(for: brand),
      agents: AutonomousAgent.demo(for: brand),
      platformSignals: PlatformFabricSignal.demo(for: brand),
      actionPackages: ActionFabricPackage.demo(for: brand),
      controlMetrics: AIControlMetric.demo(for: brand),
      governance: .demo,
      citations: AutonomousCitation.demo,
      compatibility: CompatibilityDTO(
        minClientVersion: "0.1.0",
        receivedClientVersion: "0.1.0",
        receivedSchemaHeader: "2026-05-agentic-v1",
        receivedPlatform: "ios"
      )
    )
  }
}

struct AutonomousControlPlane: Codable, Equatable {
  let experience: String
  let valueChain: String
  let systemOfAction: String
  let controlTower: String

  static func demo(for brand: AppBrand) -> AutonomousControlPlane {
    AutonomousControlPlane(
      experience: "ServiceNow Otto / Now Assist",
      valueChain: "data -> decision -> action -> trust",
      systemOfAction: "\(brand.displayName) ServiceNow Super App",
      controlTower: "AI Control Tower + CMDB + audit trail"
    )
  }
}

struct AutonomousWorkflowRun: Codable, Equatable {
  let id: String
  let title: String
  let severity: String
  let service: String
  let businessImpact: String
  let status: String
  let nextHumanDecision: String
  let steps: [AutonomousWorkflowStep]

  static func demo(for brand: AppBrand) -> AutonomousWorkflowRun {
    let isItau = brand == .itau
    return AutonomousWorkflowRun(
      id: isItau ? "AWR-ITAU-P0-20260510" : "AWR-BRAD-P1-20260510",
      title: isItau
        ? "P0 Core Pix Personnalité com execução agentic governada"
        : "P1 Pix Prime com contenção agentic governada",
      severity: isItau ? "P0" : "P1",
      service: isItau ? "Core Pix Personnalité" : "Pix Prime Mobile",
      businessImpact: isItau ? "R$ 8,4 mi em valor protegido" : "42 cases Prime protegidos",
      status: "Aguardando aprovação humana",
      nextHumanDecision: isItau
        ? "Aprovar change emergencial e comunicação executiva"
        : "Aprovar contenção no gateway e playbook Prime",
      steps: AutonomousWorkflowStep.demo(for: brand)
    )
  }
}

struct AutonomousWorkflowStep: Codable, Equatable, Identifiable {
  let id: String
  let phase: String
  let ownerAgent: String
  let action: String
  let evidence: String
  let state: String
  let requiresHumanApproval: Bool

  static func demo(for brand: AppBrand) -> [AutonomousWorkflowStep] {
    let isItau = brand == .itau
    return [
      AutonomousWorkflowStep(
        id: "sense",
        phase: "Sense",
        ownerAgent: "AIOps AI Specialist",
        action: isItau
          ? "Agrupar alertas do app, Pix, antifraude e mensageria"
          : "Agrupar latência do mobile gateway, Pix e antifraude",
        evidence: "CMDB Health 91, 7 relações órfãs, 18 CIs stale",
        state: "concluído",
        requiresHumanApproval: false
      ),
      AutonomousWorkflowStep(
        id: "decide",
        phase: "Decide",
        ownerAgent: "L1 Service Desk AI Specialist",
        action: "Classificar severidade, impacto, fila responsável e SLA",
        evidence: isItau ? "P0, cohort Personnalité, impacto executivo" : "P1, Prime, SLA 18 min",
        state: "concluído",
        requiresHumanApproval: false
      ),
      AutonomousWorkflowStep(
        id: "act",
        phase: "Act",
        ownerAgent: "CRM Case Management AI Specialist",
        action: "Criar case CSM, rascunhar comunicação e preparar handoff",
        evidence: "Citações KB, histórico omnicanal e next best action",
        state: "pronto",
        requiresHumanApproval: true
      ),
      AutonomousWorkflowStep(
        id: "govern",
        phase: "Govern",
        ownerAgent: "AI Control Tower",
        action: "Aplicar least privilege, prompt-shield, trilha auditável e rollback",
        evidence: "Política x_bank_ai_guardrail + CAB + LGPD",
        state: "aguardando humano",
        requiresHumanApproval: true
      ),
    ]
  }
}

struct AutonomousAgent: Codable, Equatable, Identifiable {
  let id: String
  let name: String
  let domain: String
  let permissionScope: String
  let currentWork: String

  static func demo(for brand: AppBrand) -> [AutonomousAgent] {
    let segment = brand.customerSegment
    return [
      AutonomousAgent(
        id: "aiops",
        name: "AIOps AI Specialist",
        domain: "IT Operations",
        permissionScope: "Observability read + incident draft",
        currentWork: "RCA contra CMDB, logs e eventos correlacionados"
      ),
      AutonomousAgent(
        id: "service-desk",
        name: "L1 Service Desk AI Specialist",
        domain: "ITSM",
        permissionScope: "Incident triage + knowledge retrieval",
        currentWork: "Triagem inicial, categorização, SLA e resumo"
      ),
      AutonomousAgent(
        id: "crm-case",
        name: "CRM Case Management AI Specialist",
        domain: "CRM / CSM",
        permissionScope: "Case draft + customer update draft",
        currentWork: "Comunicação \(segment), case CSM e handoff"
      ),
      AutonomousAgent(
        id: "risk",
        name: "Vulnerability Resolution AI Specialist",
        domain: "Security & Risk",
        permissionScope: "Risk evidence + change draft",
        currentWork: "Guardrail, exceção, change e evidências"
      ),
    ]
  }
}

struct PlatformFabricSignal: Codable, Equatable, Identifiable {
  let id: String
  let layer: String
  let title: String
  let detail: String
  let status: String
  let symbolName: String

  static func demo(for brand: AppBrand) -> [PlatformFabricSignal] {
    let segment = brand.customerSegment
    return [
      PlatformFabricSignal(
        id: "otto",
        layer: "Unified AI",
        title: "Otto entende intenção e estado do trabalho",
        detail: "Conversa vira plano com contexto, citação e próximos passos rastreáveis.",
        status: "contexto pronto",
        symbolName: "sparkles"
      ),
      PlatformFabricSignal(
        id: "action-fabric",
        layer: "Action Fabric",
        title: "MCP Server abre ações ServiceNow para agentes",
        detail: "Incidente, mudança, catálogo, case CSM e CMDB expostos como tools com policy.",
        status: "4 packages",
        symbolName: "point.3.connected.trianglepath.dotted"
      ),
      PlatformFabricSignal(
        id: "workflow-data-fabric",
        layer: "Workflow Data Fabric",
        title: "Context Engine cruza sinais internos e externos",
        detail: "CMDB, observabilidade, CRM, atendimento \(segment) e SPM viram contexto único.",
        status: "sem copiar dados",
        symbolName: "externaldrive.connected.to.line.below"
      ),
      PlatformFabricSignal(
        id: "control-tower",
        layer: "AI Control Tower",
        title: "Governança antes da execução autônoma",
        detail: "Human-in-the-loop, prompt-shield, escopo mínimo e auditoria por run.",
        status: "governado",
        symbolName: "checkmark.shield.fill"
      ),
    ]
  }
}

struct ActionFabricPackage: Codable, Equatable, Identifiable {
  let id: String
  let title: String
  let tool: String
  let target: String
  let guardrail: String
  let state: String

  static func demo(for brand: AppBrand) -> [ActionFabricPackage] {
    let isItau = brand == .itau
    return [
      ActionFabricPackage(
        id: "incident-bridge",
        title: isItau ? "Abrir ponte P0" : "Assumir war room P1",
        tool: "x_bank.incident.bridge.open",
        target: isItau ? "INC0018884" : "INC0018885",
        guardrail: "Somente cria ponte e resumo; não executa rollback.",
        state: "ready"
      ),
      ActionFabricPackage(
        id: "change-guardrail",
        title: "Aprovar guardrail CAB",
        tool: "x_bank.change.guardrail.approve",
        target: isItau ? "CHG0030005" : "CHG0030004",
        guardrail: "Exige aprovação humana e plano de retorno.",
        state: "human gate"
      ),
      ActionFabricPackage(
        id: "csm-draft",
        title: isItau ? "Draft CSM Personnalité" : "Draft CSM Prime",
        tool: "x_bank.csm.case.draft",
        target: "case draft",
        guardrail: "Rascunho com citação; envio final manual.",
        state: "draft"
      ),
      ActionFabricPackage(
        id: "cmdb-remediate",
        title: "Plano CMDB Health",
        tool: "x_bank.cmdb.health.remediate",
        target: "18 stale CIs",
        guardrail: "Cria tarefas; não altera CI crítico sem owner.",
        state: "planned"
      ),
    ]
  }
}

struct AIControlMetric: Codable, Equatable, Identifiable {
  let id: String
  let title: String
  let value: String
  let detail: String

  static func demo(for brand: AppBrand) -> [AIControlMetric] {
    [
      AIControlMetric(
        id: "agent-risk",
        title: "Agent risk",
        value: brand == .itau ? "médio" : "baixo",
        detail: "Escopo limita ação a rascunhos, ponte e aprovação guardada."
      ),
      AIControlMetric(
        id: "policy",
        title: "Policy pass",
        value: "97%",
        detail: "Prompt shield, PII logging off e trilha por correlation_id."
      ),
      AIControlMetric(
        id: "automation",
        title: "Autonomia liberada",
        value: "62%",
        detail: "Demais passos esperam humano por CAB, LGPD ou comunicação."
      ),
    ]
  }
}

struct AutonomousGovernance: Codable, Equatable {
  let humanInTheLoop: Bool
  let leastPrivilege: Bool
  let piiLoggingAllowed: Bool
  let promptInjectionShield: Bool
  let auditTrail: String

  static let demo = AutonomousGovernance(
    humanInTheLoop: true,
    leastPrivilege: true,
    piiLoggingAllowed: false,
    promptInjectionShield: true,
    auditTrail: "x_bank_ai_audit_event"
  )
}

struct AutonomousCitation: Codable, Equatable, Identifiable {
  let id: String
  let label: String
  let source: String

  static let demo = [
    AutonomousCitation(
      id: "kb",
      label: "KB001928",
      source: "Política de consentimento e comunicação digital"
    ),
    AutonomousCitation(
      id: "cmdb",
      label: "Service Graph",
      source: "CIs e relações críticas do fluxo Pix"
    ),
    AutonomousCitation(
      id: "cab",
      label: "CHG004102",
      source: "Plano de rollback e aprovação CAB"
    ),
  ]
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
