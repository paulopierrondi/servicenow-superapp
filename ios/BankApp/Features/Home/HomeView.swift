import SwiftUI

private struct ServiceNowModule: Identifiable {
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
  @EnvironmentObject private var viewModel: HomeViewModel

  @Binding var selectedTab: AppTab

  private let columns = [
    GridItem(.flexible(), spacing: BankTheme.Spacing.md),
    GridItem(.flexible(), spacing: BankTheme.Spacing.md),
  ]

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

  var body: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(spacing: BankTheme.Spacing.xl) {
            header
            commandHero
            commandMetrics
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
          .foregroundColor(.white.opacity(0.74))
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
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(node.color)
            }

            Text(node.title)
              .font(.system(size: 10, weight: .semibold, design: .rounded))
              .foregroundColor(.white.opacity(0.72))
              .lineLimit(1)
              .minimumScaleFactor(0.68)
              .frame(width: 62)
          }
          .position(x: horizontalInset + step * CGFloat(index), y: y + 24)
        }
      }
    }
  }
}
