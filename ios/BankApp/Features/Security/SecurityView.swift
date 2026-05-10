import SwiftUI

private struct DeviceTrustItem: Identifiable {
  let id = UUID()
  let name: String
  let detail: String
  let symbolName: String
  let color: Color
}

struct SecurityView: View {
  @EnvironmentObject private var authSession: AuthSession
  @EnvironmentObject private var homeViewModel: HomeViewModel

  @State private var cardFreezeEnabled = false
  @State private var consentAlertsEnabled = true
  @State private var locationShieldEnabled = true

  private let devices = [
    DeviceTrustItem(
      name: "iPhone 15 Pro",
      detail: "Este aparelho, validado por biometria",
      symbolName: "iphone.gen3",
      color: BankTheme.Palette.success
    ),
    DeviceTrustItem(
      name: "Safari macOS",
      detail: "Sessão web expira hoje",
      symbolName: "desktopcomputer",
      color: BankTheme.Palette.warning
    ),
  ]

  var body: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(spacing: BankTheme.Spacing.xl) {
            header
            riskScore
            controls
            devicesList
            compliance
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
    VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
      Text("security.eyebrow")
        .font(BankTheme.Typography.caption)
        .foregroundColor(BankTheme.Palette.brandRed)

      Text("security.title")
        .font(BankTheme.Typography.title)
        .foregroundColor(BankTheme.Palette.ink)

      Text("security.subtitle")
        .font(BankTheme.Typography.body)
        .foregroundColor(BankTheme.Palette.secondaryInk)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var riskScore: some View {
    VisualCard {
      HStack(spacing: BankTheme.Spacing.xl) {
        RiskRing(score: homeViewModel.snapshot.safetyScore)

        VStack(alignment: .leading, spacing: BankTheme.Spacing.sm) {
          Text("security.score.title")
            .font(BankTheme.Typography.section)
            .foregroundColor(BankTheme.Palette.ink)

          Text("security.score.detail")
            .font(BankTheme.Typography.body)
            .foregroundColor(BankTheme.Palette.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)

          StatusBadge(
            titleKey: "security.score.badge",
            color: BankTheme.Palette.success,
            symbolName: "checkmark.seal.fill"
          )
        }
      }
    }
  }

  private var controls: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("security.controls.title")

      VisualCard {
        VStack(spacing: BankTheme.Spacing.md) {
          ToggleRow(
            titleKey: "security.control.biometry",
            detailKey: "security.control.biometry.detail",
            symbolName: "faceid",
            color: BankTheme.Palette.success,
            isOn: $authSession.biometricEnabled
          )

          ToggleRow(
            titleKey: "security.control.trusted",
            detailKey: "security.control.trusted.detail",
            symbolName: "checkmark.shield.fill",
            color: BankTheme.Palette.attention,
            isOn: $authSession.trustedDeviceEnabled
          )

          ToggleRow(
            titleKey: "security.control.location",
            detailKey: "security.control.location.detail",
            symbolName: "location.fill",
            color: BankTheme.Palette.secure,
            isOn: $locationShieldEnabled
          )

          ToggleRow(
            titleKey: "security.control.freeze",
            detailKey: "security.control.freeze.detail",
            symbolName: "snowflake",
            color: BankTheme.Palette.brandRed,
            isOn: $cardFreezeEnabled
          )
        }
      }
    }
  }

  private var devicesList: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("security.devices.title", actionKey: "common.manage") {}

      VisualCard {
        VStack(spacing: BankTheme.Spacing.md) {
          ForEach(devices) { device in
            HStack(spacing: BankTheme.Spacing.md) {
              IconBubble(
                symbolName: device.symbolName,
                color: device.color,
                size: BankTheme.Size.compactIconBubble
              )

              VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
                Text(device.name)
                  .font(BankTheme.Typography.headline)
                  .foregroundColor(BankTheme.Palette.ink)

                Text(device.detail)
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

  private var compliance: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("security.compliance.title")

      VisualCard {
        VStack(alignment: .leading, spacing: BankTheme.Spacing.md) {
          HStack(spacing: BankTheme.Spacing.md) {
            IconBubble(
              symbolName: "doc.text.magnifyingglass",
              color: BankTheme.Palette.graphite,
              size: BankTheme.Size.compactIconBubble
            )

            VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
              Text("security.compliance.consent")
                .font(BankTheme.Typography.headline)
                .foregroundColor(BankTheme.Palette.ink)

              Text("security.compliance.detail")
                .font(BankTheme.Typography.body)
                .foregroundColor(BankTheme.Palette.secondaryInk)
            }
          }

          Toggle("security.compliance.alerts", isOn: $consentAlertsEnabled)
            .font(BankTheme.Typography.body)
            .tint(BankTheme.Palette.brandAction)
        }
      }
    }
  }
}

private struct RiskRing: View {
  let score: Int

  private var progress: Double {
    min(max(Double(score) / 100, 0), 1)
  }

  var body: some View {
    ZStack {
      Circle()
        .stroke(BankTheme.Palette.divider, lineWidth: BankTheme.Spacing.sm)

      Circle()
        .trim(from: 0, to: progress)
        .stroke(
          BankTheme.Palette.success,
          style: StrokeStyle(
            lineWidth: BankTheme.Spacing.sm,
            lineCap: .round,
            lineJoin: .round
          )
        )
        .rotationEffect(.degrees(-90))

      VStack(spacing: BankTheme.Spacing.xxs) {
        Text("\(score)")
          .font(BankTheme.Typography.display)
          .foregroundColor(BankTheme.Palette.ink)

        Text("security.score.label")
          .font(BankTheme.Typography.caption)
          .foregroundColor(BankTheme.Palette.secondaryInk)
      }
    }
    .frame(width: BankTheme.Size.riskRing, height: BankTheme.Size.riskRing)
    .accessibilityElement(children: .combine)
  }
}

private struct ToggleRow: View {
  let titleKey: LocalizedStringKey
  let detailKey: LocalizedStringKey
  let symbolName: String
  let color: Color
  @Binding var isOn: Bool

  var body: some View {
    Toggle(isOn: $isOn) {
      HStack(spacing: BankTheme.Spacing.md) {
        IconBubble(
          symbolName: symbolName,
          color: color,
          size: BankTheme.Size.compactIconBubble
        )

        VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
          Text(titleKey)
            .font(BankTheme.Typography.headline)
            .foregroundColor(BankTheme.Palette.ink)

          Text(detailKey)
            .font(BankTheme.Typography.callout)
            .foregroundColor(BankTheme.Palette.secondaryInk)
        }
      }
    }
    .tint(BankTheme.Palette.brandAction)
  }
}
