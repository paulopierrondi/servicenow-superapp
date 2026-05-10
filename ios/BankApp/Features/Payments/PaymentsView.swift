import SwiftUI

private enum CatalogMode: String, CaseIterable, Identifiable {
  case employee
  case operations
  case customer
  case portfolio

  var id: String { rawValue }

  var titleKey: LocalizedStringKey {
    switch self {
    case .employee: return "catalog.mode.employee"
    case .operations: return "catalog.mode.operations"
    case .customer: return "catalog.mode.customer"
    case .portfolio: return "catalog.mode.portfolio"
    }
  }

  var symbolName: String {
    switch self {
    case .employee: return "person.crop.rectangle.stack.fill"
    case .operations: return "wrench.and.screwdriver.fill"
    case .customer: return "person.2.fill"
    case .portfolio: return "chart.line.uptrend.xyaxis"
    }
  }
}

private struct ServiceFlow: Identifiable {
  let id: String
  let title: String
  let detail: String
  let metric: String
  let symbolName: String
  let color: Color

  static var active: [ServiceFlow] {
    [
      ServiceFlow(
        id: "itsm-pix",
        title: "Incidente correlacionado",
        detail: "Latência Pix conectada a filas, antifraude e comunicação para cliente.",
        metric: "ITSM P1",
        symbolName: "exclamationmark.triangle.fill",
        color: BankTheme.Palette.warning
      ),
      ServiceFlow(
        id: "csm-case",
        title: "Case CSM em andamento",
        detail: "Handoff com contexto, SLA, histórico omnicanal e resposta assistida.",
        metric: "CSM",
        symbolName: "person.crop.circle.badge.exclamationmark.fill",
        color: BankTheme.Palette.attention
      ),
      ServiceFlow(
        id: "spm-demand",
        title: "Demanda priorizada",
        detail: "Open Finance e consent hub avaliados por valor, risco e dependências.",
        metric: "SPM",
        symbolName: "chart.bar.doc.horizontal.fill",
        color: BankTheme.Palette.success
      ),
    ]
  }
}

struct PaymentsView: View {
  @State private var mode: CatalogMode = .operations
  @State private var requestText = ""
  @State private var impactText = ""
  @State private var generateCase = true
  @State private var createIncident = true
  @State private var linkPortfolio = true

  private var canSubmit: Bool {
    requestText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
  }

  var body: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(spacing: BankTheme.Spacing.xl) {
            header
            orchestrationComposer
            activeFlows
            serviceMetrics
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
      Text("catalog.eyebrow")
        .font(BankTheme.Typography.caption)
        .foregroundColor(BankTheme.Palette.brandRed)

      Text("catalog.title")
        .font(BankTheme.Typography.title)
        .foregroundColor(BankTheme.Palette.ink)

      Text("catalog.subtitle")
        .font(BankTheme.Typography.body)
        .foregroundColor(BankTheme.Palette.secondaryInk)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var orchestrationComposer: some View {
    VisualCard {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.lg) {
        Picker("catalog.mode.selector", selection: $mode) {
          ForEach(CatalogMode.allCases) { item in
            Text(item.titleKey).tag(item)
          }
        }
        .pickerStyle(.segmented)

        HStack(spacing: BankTheme.Spacing.md) {
          IconBubble(
            symbolName: mode.symbolName,
            color: BankTheme.Palette.brandRed,
            size: BankTheme.Size.iconBubble
          )

          VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
            Text(mode.titleKey)
              .font(BankTheme.Typography.headline)
              .foregroundColor(BankTheme.Palette.ink)

            Text("catalog.composer.detail")
              .font(BankTheme.Typography.callout)
              .foregroundColor(BankTheme.Palette.secondaryInk)
          }
        }

        VStack(spacing: BankTheme.Spacing.md) {
          TextField(
            text: $requestText,
            prompt: Text("catalog.request.placeholder")
              .foregroundColor(BankTheme.Palette.mutedInk)
          ) {
            EmptyView()
          }
          .textInputAutocapitalization(.sentences)
          .font(BankTheme.Typography.body)
          .foregroundColor(BankTheme.Palette.ink)
          .padding(BankTheme.Spacing.md)
          .background(inputBackground)

          TextField(
            text: $impactText,
            prompt: Text("catalog.impact.placeholder")
              .foregroundColor(BankTheme.Palette.mutedInk)
          ) {
            EmptyView()
          }
          .textInputAutocapitalization(.sentences)
          .font(BankTheme.Typography.body)
          .foregroundColor(BankTheme.Palette.ink)
          .padding(BankTheme.Spacing.md)
          .background(inputBackground)
        }

        VStack(spacing: BankTheme.Spacing.sm) {
          Toggle(isOn: $generateCase) {
            Text("catalog.option.case")
              .foregroundColor(BankTheme.Palette.ink)
          }
          Toggle(isOn: $createIncident) {
            Text("catalog.option.incident")
              .foregroundColor(BankTheme.Palette.ink)
          }
          Toggle(isOn: $linkPortfolio) {
            Text("catalog.option.portfolio")
              .foregroundColor(BankTheme.Palette.ink)
          }
        }
        .font(BankTheme.Typography.body)
        .tint(BankTheme.Palette.brandAction)

        Button {
          requestText = ""
          impactText = ""
        } label: {
          Label("catalog.submit", systemImage: "flowchart.fill")
        }
        .buttonStyle(.bankPrimary)
        .disabled(canSubmit == false)
        .opacity(canSubmit ? 1 : 0.48)
        .accessibilityHint(Text("catalog.submit.hint"))
      }
    }
  }

  private var activeFlows: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("catalog.active.title", actionKey: "common.manage") {}

      VisualCard {
        VStack(spacing: BankTheme.Spacing.md) {
          ForEach(ServiceFlow.active) { flow in
            HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
              IconBubble(
                symbolName: flow.symbolName,
                color: flow.color,
                size: BankTheme.Size.compactIconBubble
              )

              VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
                Text(flow.title)
                  .font(BankTheme.Typography.headline)
                  .foregroundColor(BankTheme.Palette.ink)

                Text(flow.detail)
                  .font(BankTheme.Typography.callout)
                  .foregroundColor(BankTheme.Palette.secondaryInk)
                  .fixedSize(horizontal: false, vertical: true)
              }

              Spacer(minLength: BankTheme.Spacing.sm)

              Text(flow.metric)
                .font(BankTheme.Typography.caption)
                .foregroundColor(flow.color)
                .padding(.horizontal, BankTheme.Spacing.sm)
                .padding(.vertical, BankTheme.Spacing.xs)
                .background(
                  Capsule(style: .continuous)
                    .fill(flow.color.opacity(0.12))
                )
            }
          }
        }
      }
    }
  }

  private var serviceMetrics: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("catalog.metrics.title")

      HStack(spacing: BankTheme.Spacing.md) {
        MetricPill(
          value: "6 áreas",
          titleKey: "catalog.metric.departments",
          symbolName: "point.3.connected.trianglepath.dotted",
          color: BankTheme.Palette.attention
        )

        MetricPill(
          value: "AI Search",
          titleKey: "catalog.metric.discovery",
          symbolName: "magnifyingglass.circle.fill",
          color: BankTheme.Palette.brandSecondary
        )
      }
    }
  }

  private var inputBackground: some View {
    RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
      .fill(BankTheme.Palette.appBackground)
      .overlay(
        RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
          .stroke(BankTheme.Palette.divider, lineWidth: BankTheme.Stroke.hairline)
      )
  }
}
