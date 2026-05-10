import SwiftUI

private struct ServiceNowModule: Identifiable {
  let id: String
  let title: String
  let subtitle: String
  let symbolName: String
  let color: Color
  let targetTab: AppTab
}

private struct BradescoShortcut: Identifiable {
  let id: String
  let title: String
  let subtitle: String
  let symbolName: String
  let color: Color
  let targetTab: AppTab
}

private struct CommandSignal: Identifiable {
  let id: String
  let title: String
  let detail: String
  let metric: String
  let symbolName: String
  let color: Color

  static var demo: [CommandSignal] {
    [
      CommandSignal(
        id: "ai",
        title: "Now Assist",
        detail: "Resumos, próximos passos, respostas com citação e handoff humano.",
        metric: "8 skills",
        symbolName: "sparkles",
        color: BankTheme.Palette.brandRed
      ),
      CommandSignal(
        id: "work",
        title: "Workflows vivos",
        detail: "ITSM, SPM, CSM e CRM conectados por contexto e auditoria.",
        metric: "4 domínios",
        symbolName: "point.3.connected.trianglepath.dotted",
        color: BankTheme.Palette.attention
      ),
      CommandSignal(
        id: "risk",
        title: "Controle operacional",
        detail: "Consentimento, LGPD, ZTA e evidências antes de qualquer execução.",
        metric: "94 score",
        symbolName: "shield.checkered",
        color: BankTheme.Palette.success
      ),
    ]
  }
}

struct HomeView: View {
  @EnvironmentObject private var authSession: AuthSession
  @EnvironmentObject private var brandStore: BrandStore
  @EnvironmentObject private var viewModel: HomeViewModel

  @Binding var selectedTab: AppTab

  private let columns = [
    GridItem(.flexible(), spacing: BankTheme.Spacing.md),
    GridItem(.flexible(), spacing: BankTheme.Spacing.md),
  ]

  private var bradescoGridColumns: [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: BankTheme.Spacing.md), count: 4)
  }

  private var itauDaySummary: String {
    "Bom dia, \(authSession.user.firstName). "
      + "Seu mordomo Now Assist já cruzou P0, CMDB, CSM e aprovações críticas."
  }

  private var modules: [ServiceNowModule] {
    [
      ServiceNowModule(
        id: "work",
        title: "Workspaces",
        subtitle: "ITSM, SPM, CSM e CRM",
        symbolName: "tray.full.fill",
        color: BankTheme.Palette.brandRed,
        targetTab: .now
      ),
      ServiceNowModule(
        id: "catalog",
        title: "Catálogo",
        subtitle: "Serviços e fluxos por área",
        symbolName: "square.grid.2x2.fill",
        color: BankTheme.Palette.attention,
        targetTab: .payments
      ),
      ServiceNowModule(
        id: "assist",
        title: "Now Assist",
        subtitle: "AI, chat e ações guiadas",
        symbolName: "sparkles",
        color: BankTheme.Palette.brandSecondary,
        targetTab: .support
      ),
      ServiceNowModule(
        id: "risk",
        title: "Trust",
        subtitle: "Consentimento e auditoria",
        symbolName: "shield.checkered",
        color: BankTheme.Palette.success,
        targetTab: .security
      ),
    ]
  }

  private var bradescoShortcuts: [BradescoShortcut] {
    [
      BradescoShortcut(
        id: "itsm",
        title: "ITSM",
        subtitle: "Incidentes e mudanças",
        symbolName: "wrench.and.screwdriver.fill",
        color: BankTheme.Palette.brandAction,
        targetTab: .now
      ),
      BradescoShortcut(
        id: "approvals",
        title: "Aprovações",
        subtitle: "CAB, risco e SPM",
        symbolName: "checkmark.seal.fill",
        color: BankTheme.Palette.brandAction,
        targetTab: .now
      ),
      BradescoShortcut(
        id: "catalog",
        title: "Catálogo",
        subtitle: "Pedido vira fluxo",
        symbolName: "square.grid.2x2.fill",
        color: BankTheme.Palette.brandAction,
        targetTab: .payments
      ),
      BradescoShortcut(
        id: "assist",
        title: "Now Assist",
        subtitle: "BIA com contexto Now",
        symbolName: "sparkles",
        color: BankTheme.Palette.attention,
        targetTab: .support
      ),
      BradescoShortcut(
        id: "spm",
        title: "SPM",
        subtitle: "Valor, risco e demanda",
        symbolName: "chart.line.uptrend.xyaxis",
        color: BankTheme.Palette.brandAction,
        targetTab: .now
      ),
      BradescoShortcut(
        id: "cmdb",
        title: "CMDB",
        subtitle: "Health e Service Graph",
        symbolName: "point.3.connected.trianglepath.dotted",
        color: BankTheme.Palette.brandChrome,
        targetTab: .now
      ),
      BradescoShortcut(
        id: "csm",
        title: "CSM",
        subtitle: "Cases com SLA",
        symbolName: "person.2.fill",
        color: BankTheme.Palette.brandAction,
        targetTab: .now
      ),
      BradescoShortcut(
        id: "trust",
        title: "Trust",
        subtitle: "LGPD e auditoria",
        symbolName: "shield.checkered",
        color: BankTheme.Palette.attention,
        targetTab: .security
      ),
    ]
  }

  var body: some View {
    if AppBrand.current == .bradesco {
      bradescoBody
    } else if AppBrand.current == .itau {
      itauBody
    } else {
      standardBody
    }
  }

  private var standardBody: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(spacing: BankTheme.Spacing.xl) {
            header
            commandHero
            commandMetrics
            CMDBHealthPanel()
            moduleGrid
            signals
          }
          .padding(.horizontal, BankTheme.Spacing.lg)
          .padding(.vertical, BankTheme.Spacing.xl)
        }
      }
      .navigationBarHidden(true)
    }
    .navigationViewStyle(.stack)
  }

  private var itauBody: some View {
    NavigationView {
      ZStack {
        BankTheme.Palette.brandRed.ignoresSafeArea()

        ScrollView(showsIndicators: false) {
          VStack(spacing: 0) {
            itauHero

            VStack(spacing: BankTheme.Spacing.xl) {
              CMDBHealthPanel(
                title: "CMDB Health Itaú",
                subtitle:
                  "Pix, cartões, app Personnalité, Open Finance e canais digitais em Service Graph."
              )
              commandHero
              commandMetrics
              moduleGrid
              signals
            }
            .padding(.horizontal, BankTheme.Spacing.lg)
            .padding(.top, BankTheme.Spacing.xl)
            .padding(.bottom, BankTheme.Spacing.xxxl)
            .frame(maxWidth: .infinity)
            .background(Color(bankHex: 0xFFF7F0))
          }
        }
      }
      .navigationBarHidden(true)
    }
    .navigationViewStyle(.stack)
  }

  private var bradescoBody: some View {
    NavigationView {
      ZStack {
        BankTheme.Palette.brandChrome.ignoresSafeArea()

        ScrollView(showsIndicators: false) {
          VStack(spacing: 0) {
            bradescoHero

            VStack(alignment: .leading, spacing: BankTheme.Spacing.xl) {
              bradescoShortcutsGrid
              CMDBHealthPanel(
                title: "CMDB Health Bradesco",
                subtitle: "Pix, mobile gateway, antifraude e atendimento mapeados no Service Graph."
              )
              bradescoOperationalCards
              signals
            }
            .padding(.horizontal, BankTheme.Spacing.lg)
            .padding(.top, BankTheme.Spacing.xl)
            .padding(.bottom, BankTheme.Spacing.xxxl)
            .frame(maxWidth: .infinity)
            .background(Color.white)
          }
        }
      }
      .navigationBarHidden(true)
    }
    .navigationViewStyle(.stack)
  }

  private var itauHero: some View {
    ZStack(alignment: .bottomLeading) {
      LinearGradient(
        colors: [
          BankTheme.Palette.brandRed,
          Color(bankHex: 0xFF8A1F),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(alignment: .leading, spacing: BankTheme.Spacing.lg) {
        HStack(alignment: .center) {
          VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
            Text("SERVICENOW SUPER APP • ITAÚ")
              .font(BankTheme.Typography.caption)
              .foregroundColor(.white.opacity(0.9))

            Text("NowOS Command Center")
              .font(BankTheme.Typography.title)
              .foregroundColor(.white)
          }

          Spacer(minLength: BankTheme.Spacing.md)

          Text("itaú")
            .font(BankTheme.Typography.section)
            .foregroundColor(BankTheme.Palette.brandSecondary)
            .padding(.horizontal, BankTheme.Spacing.md)
            .padding(.vertical, BankTheme.Spacing.sm)
            .background(
              RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
                .fill(Color.white)
            )
        }

        Text(itauDaySummary)
          .font(BankTheme.Typography.callout)
          .foregroundColor(.white.opacity(0.92))
          .fixedSize(horizontal: false, vertical: true)

        HStack(spacing: BankTheme.Spacing.md) {
          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            StatusBadge(
              title: "P0 aberto",
              color: BankTheme.Palette.brandSecondary,
              symbolName: "flame.fill"
            )

            Text("Core Pix indisponível para cohort Personnalité")
              .font(BankTheme.Typography.headline)
              .foregroundColor(.white)
              .fixedSize(horizontal: false, vertical: true)
          }

          Spacer(minLength: BankTheme.Spacing.md)

          Button {
            selectedTab = .support
          } label: {
            Image(systemName: "sparkles")
              .font(BankTheme.Typography.title)
              .foregroundColor(BankTheme.Palette.brandSecondary)
              .frame(width: 54, height: 54)
              .background(Circle().fill(Color.white))
          }
          .accessibilityLabel(Text("Abrir mordomo Now Assist"))
        }

        Button {
          selectedTab = .support
        } label: {
          Label("Ver meu dia com Now Assist", systemImage: "arrow.up.right.circle.fill")
            .font(BankTheme.Typography.headline)
            .foregroundColor(BankTheme.Palette.brandSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BankTheme.Spacing.md)
            .background(
              RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
                .fill(Color.white)
            )
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal, BankTheme.Spacing.lg)
      .padding(.top, BankTheme.Spacing.xxxl)
      .padding(.bottom, BankTheme.Spacing.xxl)
    }
  }

  private var bradescoHero: some View {
    ZStack(alignment: .bottom) {
      LinearGradient(
        colors: [
          BankTheme.Palette.brandChrome,
          BankTheme.Palette.brandChromeDark,
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      BradescoWave()
        .fill(Color.white.opacity(0.34))
        .frame(height: 74)

      VStack(alignment: .leading, spacing: BankTheme.Spacing.lg) {
        HStack(alignment: .center) {
          Text("Olá, \(authSession.user.firstName) CENTRAL")
            .font(BankTheme.Typography.section)
            .foregroundColor(.white)

          Spacer(minLength: BankTheme.Spacing.sm)

          Button {
            selectedTab = .support
          } label: {
            Image(systemName: "bell.badge.fill")
              .font(BankTheme.Typography.title)
              .foregroundColor(.white)
          }
          .accessibilityLabel(Text("Notificações ServiceNow"))

          Button {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
              brandStore.resetSelection()
            }
          } label: {
            Image(systemName: "arrow.right.square")
              .font(BankTheme.Typography.title)
              .foregroundColor(.white)
          }
          .accessibilityLabel(Text("brand.switch"))
        }

        VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
          Text("NowOS Command Center")
            .font(BankTheme.Typography.title)
            .foregroundColor(.white)

          Text("Seu dia operacional, riscos do CMDB e próximos passos em uma visão Bradesco Prime.")
            .font(BankTheme.Typography.callout)
            .foregroundColor(.white.opacity(0.9))
            .fixedSize(horizontal: false, vertical: true)
        }

        HStack(alignment: .center, spacing: BankTheme.Spacing.md) {
          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            Text("P1 em andamento")
              .font(BankTheme.Typography.callout)
              .foregroundColor(.white.opacity(0.86))

            Text("Pix com latência")
              .font(BankTheme.Typography.section)
              .foregroundColor(.white)
          }

          Spacer(minLength: BankTheme.Spacing.md)

          Button {
            selectedTab = .now
          } label: {
            Label("Ver extrato Now", systemImage: "chevron.right")
              .font(BankTheme.Typography.callout)
              .foregroundColor(.white)
          }
          .buttonStyle(.plain)
        }

        Button {
          selectedTab = .support
        } label: {
          HStack(spacing: BankTheme.Spacing.sm) {
            Text("BIA")
              .font(BankTheme.Typography.caption)
              .foregroundColor(BankTheme.Palette.brandAction)
              .frame(width: 44, height: 44)
              .background(Circle().fill(Color.white))

            Text("BIA + Now Assist: P1, CMDB e CSM lidos.")
              .font(BankTheme.Typography.callout)
              .foregroundColor(.white)
              .lineLimit(2)

            Spacer(minLength: BankTheme.Spacing.sm)

            Image(systemName: "magnifyingglass")
              .font(BankTheme.Typography.section)
              .foregroundColor(.white)
          }
          .padding(BankTheme.Spacing.sm)
          .background(
            Capsule(style: .continuous)
              .fill(BankTheme.Palette.brandChromeDark.opacity(0.72))
          )
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal, BankTheme.Spacing.lg)
      .padding(.top, BankTheme.Spacing.xxxl)
      .padding(.bottom, BankTheme.Spacing.xxl)
    }
  }

  private var bradescoShortcutsGrid: some View {
    VStack(alignment: .leading, spacing: BankTheme.Spacing.md) {
      Text("Favoritos operacionais")
        .font(BankTheme.Typography.section)
        .foregroundColor(BankTheme.Palette.ink)

      LazyVGrid(columns: bradescoGridColumns, spacing: BankTheme.Spacing.lg) {
        ForEach(bradescoShortcuts) { shortcut in
          BradescoShortcutTile(shortcut: shortcut) {
            selectedTab = shortcut.targetTab
          }
        }
      }
    }
  }

  private var bradescoOperationalCards: some View {
    VStack(alignment: .leading, spacing: BankTheme.Spacing.md) {
      Text("Jornadas ServiceNow")
        .font(BankTheme.Typography.section)
        .foregroundColor(BankTheme.Palette.ink)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: BankTheme.Spacing.md) {
          BradescoOperationalCard(
            title: "P1 Pix contestado",
            detail: "Now Assist correlaciona cliente, gateway, antifraude, CSM e incidente.",
            symbolName: "exclamationmark.triangle.fill",
            color: BankTheme.Palette.brandChrome
          ) {
            selectedTab = .now
          }

          BradescoOperationalCard(
            title: "Mordomo operacional",
            detail: "Resumo do dia, aprovações, riscos e próximos passos para o gerente.",
            symbolName: "sparkles",
            color: BankTheme.Palette.brandAction
          ) {
            selectedTab = .support
          }
        }
        .padding(.horizontal, BankTheme.Spacing.xs)
      }
      .padding(.horizontal, -BankTheme.Spacing.xs)
    }
  }

  private var header: some View {
    HStack(alignment: .center, spacing: BankTheme.Spacing.md) {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
        Text(
          String(
            format: NSLocalizedString(
              "command.eyebrow.format", comment: "REVISÃO PT-BR HUMANA OBRIGATÓRIA"),
            AppBrand.current.displayName.uppercased())
        )
        .font(BankTheme.Typography.caption)
        .foregroundColor(BankTheme.Palette.brandRed)

        Text("command.title")
          .font(BankTheme.Typography.title)
          .foregroundColor(BankTheme.Palette.ink)

        Text("command.subtitle")
          .font(BankTheme.Typography.body)
          .foregroundColor(BankTheme.Palette.secondaryInk)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: BankTheme.Spacing.sm)

      StatusBadge(
        title: authSession.user.segment,
        color: BankTheme.Palette.brandSecondary,
        symbolName: "building.2.fill"
      )
    }
  }

  private var commandHero: some View {
    VisualCard(fill: BankTheme.Palette.graphite) {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.lg) {
        HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            Text("command.hero.eyebrow")
              .font(BankTheme.Typography.caption)
              .foregroundColor(BankTheme.Palette.brandRed)

            Text("command.hero.title")
              .font(BankTheme.Typography.title)
              .foregroundColor(.white)
              .fixedSize(horizontal: false, vertical: true)
          }

          Spacer(minLength: BankTheme.Spacing.sm)

          IconBubble(
            symbolName: "dot.radiowaves.left.and.right",
            color: BankTheme.Palette.brandRed,
            size: BankTheme.Size.iconBubble
          )
        }

        Text("command.hero.detail")
          .font(BankTheme.Typography.body)
          .foregroundColor(.white.opacity(0.84))
          .fixedSize(horizontal: false, vertical: true)

        ProcessGraph()
          .frame(height: 138)

        HStack(spacing: BankTheme.Spacing.sm) {
          StatusBadge(
            titleKey: "command.badge.platform",
            color: BankTheme.Palette.success,
            symbolName: "checkmark.seal.fill"
          )

          StatusBadge(
            titleKey: "command.badge.ai",
            color: BankTheme.Palette.attention,
            symbolName: "sparkles"
          )
        }

        Button {
          selectedTab = .now
        } label: {
          Label("command.hero.open", systemImage: "arrow.up.right.circle.fill")
        }
        .buttonStyle(.bankPrimary)
      }
    }
  }

  private var commandMetrics: some View {
    HStack(spacing: BankTheme.Spacing.md) {
      MetricPill(
        value: "4",
        titleKey: "command.metric.domains",
        symbolName: "rectangle.connected.to.line.below",
        color: BankTheme.Palette.brandRed
      )

      MetricPill(
        value: viewModel.isLoading ? "..." : "42 min",
        titleKey: "command.metric.time",
        symbolName: "bolt.fill",
        color: BankTheme.Palette.warning
      )
    }
  }

  private var moduleGrid: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("command.modules.title")

      LazyVGrid(columns: columns, spacing: BankTheme.Spacing.md) {
        ForEach(modules) { module in
          ActionTile(
            title: module.title,
            subtitle: module.subtitle,
            symbolName: module.symbolName,
            color: module.color
          ) {
            selectedTab = module.targetTab
          }
        }
      }
    }
  }

  private var signals: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("command.signals.title", actionKey: "common.review") {
        selectedTab = .support
      }

      ForEach(CommandSignal.demo) { signal in
        VisualCard {
          HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
            IconBubble(
              symbolName: signal.symbolName,
              color: signal.color,
              size: BankTheme.Size.compactIconBubble
            )

            VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
              HStack(alignment: .firstTextBaseline) {
                Text(signal.title)
                  .font(BankTheme.Typography.headline)
                  .foregroundColor(BankTheme.Palette.ink)

                Spacer(minLength: BankTheme.Spacing.sm)

                Text(signal.metric)
                  .font(BankTheme.Typography.caption)
                  .foregroundColor(signal.color)
              }

              Text(signal.detail)
                .font(BankTheme.Typography.body)
                .foregroundColor(BankTheme.Palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
            }
          }
        }
      }
    }
  }
}

private struct BradescoShortcutTile: View {
  let shortcut: BradescoShortcut
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: BankTheme.Spacing.xs) {
        Image(systemName: shortcut.symbolName)
          .font(.system(size: 24, weight: .semibold, design: .default))
          .foregroundColor(shortcut.color)
          .frame(width: 58, height: 58)
          .background(
            RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
              .fill(Color.white)
              .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 6)
          )

        Text(shortcut.title)
          .font(BankTheme.Typography.caption)
          .foregroundColor(BankTheme.Palette.secondaryInk)
          .lineLimit(2)
          .multilineTextAlignment(.center)
          .minimumScaleFactor(0.9)
          .frame(height: 34, alignment: .top)
      }
      .frame(maxWidth: .infinity)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(Text(shortcut.title))
    .accessibilityHint(Text(shortcut.subtitle))
  }
}

private struct BradescoOperationalCard: View {
  let title: String
  let detail: String
  let symbolName: String
  let color: Color
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: BankTheme.Spacing.md) {
        IconBubble(
          symbolName: symbolName,
          color: color,
          size: BankTheme.Size.iconBubble
        )

        VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
          Text(title)
            .font(BankTheme.Typography.headline)
            .foregroundColor(BankTheme.Palette.ink)

          Text(detail)
            .font(BankTheme.Typography.callout)
            .foregroundColor(BankTheme.Palette.secondaryInk)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: BankTheme.Spacing.sm)

        Image(systemName: "chevron.right")
          .font(BankTheme.Typography.callout)
          .foregroundColor(color)
      }
      .frame(width: 304, alignment: .leading)
      .frame(minHeight: 126, alignment: .leading)
      .padding(BankTheme.Spacing.md)
      .background(
        RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
          .fill(Color.white)
          .shadow(color: Color.black.opacity(0.09), radius: 18, x: 0, y: 8)
      )
    }
    .buttonStyle(.plain)
  }
}

private struct BradescoWave: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: 0, y: rect.height * 0.58))
    path.addCurve(
      to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.54),
      control1: CGPoint(x: rect.width * 0.18, y: rect.height * 0.18),
      control2: CGPoint(x: rect.width * 0.32, y: rect.height * 0.92)
    )
    path.addCurve(
      to: CGPoint(x: rect.width, y: rect.height * 0.46),
      control1: CGPoint(x: rect.width * 0.7, y: rect.height * 0.16),
      control2: CGPoint(x: rect.width * 0.84, y: rect.height * 0.84)
    )
    path.addLine(to: CGPoint(x: rect.width, y: rect.height))
    path.addLine(to: CGPoint(x: 0, y: rect.height))
    path.closeSubpath()
    return path
  }
}

private struct ProcessGraph: View {
  private let nodes: [(id: String, title: String, symbol: String, color: Color)] = [
    ("intent", "Intenção", "person.crop.circle.fill", BankTheme.Palette.brandRed),
    ("assist", "Now Assist", "sparkles", BankTheme.Palette.warning),
    ("csm", "CSM", "person.2.fill", BankTheme.Palette.attention),
    ("crm", "CRM", "scope", BankTheme.Palette.brandSecondary),
    ("work", "Work", "wrench.and.screwdriver.fill", BankTheme.Palette.success),
  ]

  var body: some View {
    GeometryReader { proxy in
      let horizontalInset: CGFloat = 32
      let width = max(proxy.size.width - horizontalInset * 2, 1)
      let step = width / CGFloat(max(nodes.count - 1, 1))
      let y = proxy.size.height * 0.42

      ZStack(alignment: .topLeading) {
        Path { path in
          path.move(to: CGPoint(x: horizontalInset, y: y))
          path.addLine(to: CGPoint(x: horizontalInset + width, y: y))
        }
        .stroke(Color.white.opacity(0.16), style: StrokeStyle(lineWidth: 3, lineCap: .round))

        Path { path in
          path.move(to: CGPoint(x: horizontalInset, y: y))
          path.addLine(to: CGPoint(x: horizontalInset + width * 0.76, y: y))
        }
        .stroke(
          BankTheme.Palette.brandRed,
          style: StrokeStyle(lineWidth: 3, lineCap: .round)
        )

        ForEach(Array(nodes.enumerated()), id: \.offset) { index, node in
          VStack(spacing: BankTheme.Spacing.xs) {
            ZStack {
              Circle()
                .fill(node.color.opacity(0.18))
                .frame(width: 46, height: 46)

              Image(systemName: node.symbol)
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundColor(node.color)
            }

            Text(node.title)
              .font(BankTheme.Typography.micro)
              .foregroundColor(.white.opacity(0.82))
              .lineLimit(2)
              .multilineTextAlignment(.center)
              .minimumScaleFactor(0.9)
              .frame(width: 74)
          }
          .position(x: horizontalInset + step * CGFloat(index), y: y + 24)
        }
      }
    }
  }
}
