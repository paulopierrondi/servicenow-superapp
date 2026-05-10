import SwiftUI

struct HomeView: View {
  @EnvironmentObject private var authSession: AuthSession
  @EnvironmentObject private var viewModel: HomeViewModel

  @Binding var selectedTab: AppTab

  private let columns = [
    GridItem(.flexible(), spacing: BankTheme.Spacing.md),
    GridItem(.flexible(), spacing: BankTheme.Spacing.md),
  ]

  var body: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(spacing: BankTheme.Spacing.xl) {
            header
            balanceHero
            metrics
            quickActions
            insights
            recentTransactions
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
              "home.eyebrow.format", comment: "REVISÃO PT-BR HUMANA OBRIGATÓRIA"),
            AppBrand.current.displayName.uppercased())
        )
        .font(BankTheme.Typography.caption)
        .foregroundColor(BankTheme.Palette.brandRed)

        Text(
          String(
            format: NSLocalizedString(
              "home.greeting.format", comment: "REVISÃO PT-BR HUMANA OBRIGATÓRIA"),
            authSession.user.firstName)
        )
        .font(BankTheme.Typography.title)
        .foregroundColor(BankTheme.Palette.ink)
      }

      Spacer(minLength: BankTheme.Spacing.sm)

      StatusBadge(
        title: authSession.user.segment,
        color: BankTheme.Palette.brandSecondary,
        symbolName: "star.fill"
      )
    }
  }

  private var balanceHero: some View {
    VisualCard(fill: BankTheme.Palette.graphite) {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.lg) {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            Text("home.balance.title")
              .font(BankTheme.Typography.callout)
              .foregroundColor(.white.opacity(0.72))

            Text(
              authSession.isBalanceVisible
                ? MoneyFormatter.string(from: viewModel.snapshot.availableBalance) : "R$ ----"
            )
            .font(BankTheme.Typography.amount)
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.64)
          }

          Spacer(minLength: BankTheme.Spacing.md)

          Button {
            Task { await authSession.toggleBalanceVisibility() }
          } label: {
            Image(systemName: authSession.isBalanceVisible ? "eye.slash.fill" : "eye.fill")
              .frame(width: BankTheme.Size.iconButton, height: BankTheme.Size.iconButton)
              .background(
                Circle()
                  .fill(Color.white.opacity(0.12))
              )
          }
          .foregroundColor(.white)
          .accessibilityLabel(Text("home.balance.visibility"))
          .accessibilityHint(Text("home.balance.visibility.hint"))
        }

        HStack(spacing: BankTheme.Spacing.sm) {
          StatusBadge(
            titleKey: "home.security.badge",
            color: BankTheme.Palette.success,
            symbolName: "checkmark.seal.fill"
          )

          StatusBadge(
            titleKey: "home.now.badge",
            color: BankTheme.Palette.attention,
            symbolName: "sparkles"
          )
        }

        Button {
          selectedTab = .payments
        } label: {
          Label("home.primary.action", systemImage: "qrcode.viewfinder")
        }
        .buttonStyle(.bankPrimary)
      }
    }
    .accessibilityElement(children: .contain)
  }

  private var metrics: some View {
    HStack(spacing: BankTheme.Spacing.md) {
      MetricPill(
        value: MoneyFormatter.compactString(from: viewModel.snapshot.investmentBalance),
        titleKey: "home.metric.investments",
        symbolName: "chart.line.uptrend.xyaxis",
        color: BankTheme.Palette.secure
      )

      MetricPill(
        value: "\(viewModel.snapshot.safetyScore)",
        titleKey: "home.metric.security",
        symbolName: "shield.checkered",
        color: BankTheme.Palette.attention
      )
    }
  }

  private var quickActions: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("home.actions.title")

      LazyVGrid(columns: columns, spacing: BankTheme.Spacing.md) {
        ForEach(viewModel.visibleHomeCards) { card in
          ActionTile(
            title: card.title,
            subtitle: card.subtitle,
            symbolName: symbol(for: card.action),
            color: color(for: card.action)
          ) {
            selectedTab = tab(for: card.action)
          }
        }
      }
    }
  }

  private var insights: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("home.insights.title", actionKey: "common.review") {
        selectedTab = .support
      }

      ForEach(viewModel.insights) { insight in
        VisualCard {
          HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
            IconBubble(
              symbolName: insight.symbolName,
              color: BankTheme.Palette.brandRed,
              size: BankTheme.Size.compactIconBubble
            )

            VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
              Text(insight.title)
                .font(BankTheme.Typography.headline)
                .foregroundColor(BankTheme.Palette.ink)

              Text(insight.detail)
                .font(BankTheme.Typography.body)
                .foregroundColor(BankTheme.Palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
            }
          }
        }
      }
    }
  }

  private var recentTransactions: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("home.transactions.title", actionKey: "common.see.all") {
        selectedTab = .now
      }

      VisualCard {
        VStack(spacing: BankTheme.Spacing.md) {
          ForEach(viewModel.transactions) { transaction in
            HStack(spacing: BankTheme.Spacing.md) {
              IconBubble(
                symbolName: transaction.symbolName,
                color: transaction.isIncoming
                  ? BankTheme.Palette.success : BankTheme.Palette.brandRed,
                size: BankTheme.Size.compactIconBubble
              )

              VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
                Text(transaction.merchant)
                  .font(BankTheme.Typography.headline)
                  .foregroundColor(BankTheme.Palette.ink)

                Text(transaction.category)
                  .font(BankTheme.Typography.caption)
                  .foregroundColor(BankTheme.Palette.secondaryInk)
              }

              Spacer(minLength: BankTheme.Spacing.sm)

              Text(transactionAmount(transaction))
                .font(BankTheme.Typography.callout)
                .foregroundColor(
                  transaction.isIncoming ? BankTheme.Palette.success : BankTheme.Palette.ink)
            }
          }
        }
      }
    }
  }

  private func symbol(for action: String) -> String {
    switch action {
    case "open_balance": return "wallet.pass.fill"
    case "open_payments": return "qrcode.viewfinder"
    case "open_investments": return "chart.line.uptrend.xyaxis.circle.fill"
    case "open_security": return "shield.lefthalf.filled"
    case "open_support": return "bubble.left.and.bubble.right.fill"
    default: return "square.grid.2x2.fill"
    }
  }

  private func color(for action: String) -> Color {
    switch action {
    case "open_balance": return BankTheme.Palette.graphite
    case "open_payments": return BankTheme.Palette.brandRed
    case "open_investments": return BankTheme.Palette.secure
    case "open_security": return BankTheme.Palette.attention
    case "open_support": return BankTheme.Palette.brandSecondary
    default: return BankTheme.Palette.brandRed
    }
  }

  private func tab(for action: String) -> AppTab {
    switch action {
    case "open_payments": return .payments
    case "open_security": return .security
    case "open_support": return .support
    default: return .home
    }
  }

  private func transactionAmount(_ transaction: TransactionItem) -> String {
    let prefix = transaction.isIncoming ? "+" : "-"
    return "\(prefix) \(MoneyFormatter.string(from: transaction.amount))"
  }
}
