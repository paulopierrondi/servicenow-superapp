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
