import SwiftUI

private struct ProfileMenuItem: Identifiable {
  let id = UUID()
  let titleKey: LocalizedStringKey
  let detailKey: LocalizedStringKey
  let symbolName: String
  let color: Color
}

struct ProfileView: View {
  @EnvironmentObject private var authSession: AuthSession
  @EnvironmentObject private var homeViewModel: HomeViewModel

  @State private var openFinanceEnabled = true
  @State private var marketingOptIn = false
  @State private var telemetryOptIn = true

  private let menuItems = [
    ProfileMenuItem(
      titleKey: "profile.menu.cards",
      detailKey: "profile.menu.cards.detail",
      symbolName: "creditcard.fill",
      color: BankTheme.Palette.brandSecondary
    ),
    ProfileMenuItem(
      titleKey: "profile.menu.investments",
      detailKey: "profile.menu.investments.detail",
      symbolName: "chart.pie.fill",
      color: BankTheme.Palette.secure
    ),
    ProfileMenuItem(
      titleKey: "profile.menu.insurance",
      detailKey: "profile.menu.insurance.detail",
      symbolName: "umbrella.fill",
      color: BankTheme.Palette.attention
    ),
    ProfileMenuItem(
      titleKey: "profile.menu.benefits",
      detailKey: "profile.menu.benefits.detail",
      symbolName: "giftcard.fill",
      color: BankTheme.Palette.brandRed
    ),
  ]

  var body: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(spacing: BankTheme.Spacing.xl) {
            header
            portfolio
            menu
            consent
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
    VisualCard(fill: BankTheme.Palette.graphite) {
      HStack(spacing: BankTheme.Spacing.md) {
        ZStack {
          Circle()
            .fill(BankTheme.Palette.brandRed)

          Text(String(authSession.user.firstName.prefix(1)))
            .font(BankTheme.Typography.title)
            .foregroundColor(.white)
        }
        .frame(width: BankTheme.Size.iconBubble, height: BankTheme.Size.iconBubble)

        VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
          Text(authSession.user.firstName)
            .font(BankTheme.Typography.section)
            .foregroundColor(.white)

          Text(authSession.user.segment)
            .font(BankTheme.Typography.callout)
            .foregroundColor(.white.opacity(0.72))
        }

        Spacer(minLength: BankTheme.Spacing.sm)

        Image(systemName: "gearshape.fill")
          .foregroundColor(.white)
          .frame(width: BankTheme.Size.iconButton, height: BankTheme.Size.iconButton)
          .background(Circle().fill(Color.white.opacity(0.12)))
          .accessibilityLabel(Text("profile.settings"))
      }
    }
  }

  private var portfolio: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("profile.portfolio.title")

      HStack(spacing: BankTheme.Spacing.md) {
        MetricPill(
          value: MoneyFormatter.compactString(from: homeViewModel.snapshot.creditLimit),
          titleKey: "profile.metric.limit",
          symbolName: "creditcard.fill",
          color: BankTheme.Palette.brandSecondary
        )

        MetricPill(
          value: MoneyFormatter.compactString(from: homeViewModel.snapshot.investmentBalance),
          titleKey: "profile.metric.assets",
          symbolName: "chart.line.uptrend.xyaxis",
          color: BankTheme.Palette.secure
        )
      }
    }
  }

  private var menu: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("profile.superapp.title")

      VisualCard {
        VStack(spacing: BankTheme.Spacing.md) {
          ForEach(menuItems) { item in
            HStack(spacing: BankTheme.Spacing.md) {
              IconBubble(
                symbolName: item.symbolName,
                color: item.color,
                size: BankTheme.Size.compactIconBubble
              )

              VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
                Text(item.titleKey)
                  .font(BankTheme.Typography.headline)
                  .foregroundColor(BankTheme.Palette.ink)

                Text(item.detailKey)
                  .font(BankTheme.Typography.callout)
                  .foregroundColor(BankTheme.Palette.secondaryInk)
              }

              Spacer(minLength: BankTheme.Spacing.sm)

              Image(systemName: "chevron.right")
                .font(BankTheme.Typography.caption)
                .foregroundColor(BankTheme.Palette.mutedInk)
            }
          }
        }
      }
    }
  }

  private var consent: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("profile.consent.title")

      VisualCard {
        VStack(alignment: .leading, spacing: BankTheme.Spacing.md) {
          Toggle("profile.consent.openfinance", isOn: $openFinanceEnabled)
          Toggle("profile.consent.telemetry", isOn: $telemetryOptIn)
          Toggle("profile.consent.marketing", isOn: $marketingOptIn)

          Text("profile.consent.note")
            .font(BankTheme.Typography.callout)
            .foregroundColor(BankTheme.Palette.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)
        }
        .font(BankTheme.Typography.body)
        .tint(BankTheme.Palette.brandRed)
      }
    }
  }
}
