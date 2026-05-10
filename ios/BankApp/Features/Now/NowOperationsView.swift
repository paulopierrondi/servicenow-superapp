import SwiftUI

private enum NowWorkspace: String, CaseIterable, Identifiable {
  case itsm
  case spm

  var id: String { rawValue }

  var titleKey: LocalizedStringKey {
    switch self {
    case .itsm: return "now.workspace.itsm"
    case .spm: return "now.workspace.spm"
    }
  }

  var domain: NowWorkDomain {
    switch self {
    case .itsm: return .itsm
    case .spm: return .spm
    }
  }
}

struct NowOperationsView: View {
  @Binding var selectedTab: AppTab

  @State private var workspace: NowWorkspace = .itsm
  @State private var searchText = ""
  @State private var voiceModeEnabled = false
  @State private var offlineQueueEnabled = true

  private var workItems: [NowWorkItem] {
    switch workspace {
    case .itsm: return NowWorkItem.demoITSM
    case .spm: return NowWorkItem.demoSPM
    }
  }

  var body: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(spacing: BankTheme.Spacing.xl) {
            header
            universalSearch
            assistantPanel
            launcher
            actionInbox
            knowledgeAnswer
            workspaceSelector
            commandCenter
            workstream
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
      Text(
        String(
          format: NSLocalizedString(
            "now.eyebrow.format", comment: "REVISÃO PT-BR HUMANA OBRIGATÓRIA"),
          AppBrand.current.displayName.uppercased())
      )
      .font(BankTheme.Typography.caption)
      .foregroundColor(BankTheme.Palette.brandRed)

      Text("now.title")
        .font(BankTheme.Typography.title)
        .foregroundColor(BankTheme.Palette.ink)
        .fixedSize(horizontal: false, vertical: true)

      Text("now.subtitle")
        .font(BankTheme.Typography.body)
        .foregroundColor(BankTheme.Palette.secondaryInk)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var universalSearch: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      HStack(spacing: BankTheme.Spacing.sm) {
        Image(systemName: "magnifyingglass")
          .foregroundColor(BankTheme.Palette.mutedInk)

        TextField("now.search.placeholder", text: $searchText)
          .textInputAutocapitalization(.sentences)
          .font(BankTheme.Typography.body)

        Button {
          voiceModeEnabled.toggle()
        } label: {
          Image(systemName: voiceModeEnabled ? "waveform.circle.fill" : "mic.circle.fill")
            .font(BankTheme.Typography.title)
            .foregroundColor(BankTheme.Palette.brandRed)
        }
        .accessibilityLabel(Text("now.search.voice"))
      }
      .padding(BankTheme.Spacing.md)
      .background(
        RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
          .fill(BankTheme.Palette.surface)
          .overlay(
            RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
              .stroke(BankTheme.Palette.divider, lineWidth: BankTheme.Stroke.hairline)
          )
      )

      Toggle("now.offline.queue", isOn: $offlineQueueEnabled)
        .font(BankTheme.Typography.callout)
        .tint(BankTheme.Palette.brandRed)
        .padding(.horizontal, BankTheme.Spacing.xs)
    }
  }

  private var assistantPanel: some View {
    VisualCard(fill: BankTheme.Palette.graphite) {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.lg) {
        HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
          IconBubble(
            symbolName: "sparkles",
            color: BankTheme.Palette.gold,
            size: BankTheme.Size.iconBubble
          )

          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            Text("now.assist.title")
              .font(BankTheme.Typography.section)
              .foregroundColor(.white)

            Text("now.assist.detail")
              .font(BankTheme.Typography.body)
              .foregroundColor(.white.opacity(0.72))
              .fixedSize(horizontal: false, vertical: true)
          }
        }

        HStack(spacing: BankTheme.Spacing.sm) {
          StatusBadge(
            titleKey: "now.badge.itsm",
            color: BankTheme.Palette.success,
            symbolName: "checkmark.seal.fill"
          )

          StatusBadge(
            titleKey: "now.badge.spm",
            color: BankTheme.Palette.attention,
            symbolName: "chart.xyaxis.line"
          )
        }

        Button {
          selectedTab = .support
        } label: {
          Label("now.assist.open", systemImage: "bubble.left.and.text.bubble.right.fill")
        }
        .buttonStyle(.bankPrimary)
      }
    }
  }

  private var workspaceSelector: some View {
    Picker("now.workspace.selector", selection: $workspace) {
      ForEach(NowWorkspace.allCases) { workspace in
        Text(workspace.titleKey).tag(workspace)
      }
    }
    .pickerStyle(.segmented)
    .tint(BankTheme.Palette.brandRed)
  }

  private var launcher: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("now.launcher.title")

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: BankTheme.Spacing.md) {
          ForEach(NowLauncherItem.demo) { item in
            LauncherTile(item: item) {
              searchText = item.title
            }
          }
        }
        .padding(.horizontal, BankTheme.Spacing.xs)
      }
      .padding(.horizontal, -BankTheme.Spacing.xs)
    }
  }

  private var actionInbox: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("now.actions.title")

      ForEach(NowActionItem.demo) { item in
        ActionItemCard(item: item) {
          searchText = item.title
        }
      }
    }
  }

  private var knowledgeAnswer: some View {
    VisualCard {
      HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
        IconBubble(
          symbolName: "quote.bubble.fill",
          color: BankTheme.Palette.gold,
          size: BankTheme.Size.compactIconBubble
        )

        VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
          Text("now.answer.title")
            .font(BankTheme.Typography.caption)
            .foregroundColor(BankTheme.Palette.brandRed)

          Text(NowKnowledgeAnswer.demo.question)
            .font(BankTheme.Typography.headline)
            .foregroundColor(BankTheme.Palette.ink)
            .fixedSize(horizontal: false, vertical: true)

          Text(NowKnowledgeAnswer.demo.answer)
            .font(BankTheme.Typography.body)
            .foregroundColor(BankTheme.Palette.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)

          Text(NowKnowledgeAnswer.demo.citation)
            .font(BankTheme.Typography.caption)
            .foregroundColor(BankTheme.Palette.mutedInk)
        }
      }
    }
  }

  private var commandCenter: some View {
    HStack(spacing: BankTheme.Spacing.md) {
      MetricPill(
        value: workspace == .itsm ? "18 min" : "72%",
        titleKey: workspace == .itsm ? "now.metric.sla" : "now.metric.health",
        symbolName: workspace == .itsm ? "timer" : "chart.line.uptrend.xyaxis",
        color: workspace == .itsm ? BankTheme.Palette.warning : BankTheme.Palette.secure
      )

      MetricPill(
        value: workspace == .itsm ? "3" : "R$ 8,4 mi",
        titleKey: workspace == .itsm ? "now.metric.queue" : "now.metric.value",
        symbolName: workspace == .itsm ? "tray.full.fill" : "banknote.fill",
        color: BankTheme.Palette.brandRed
      )
    }
  }

  private var workstream: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader(workspace == .itsm ? "now.itsm.title" : "now.spm.title")

      ForEach(workItems) { item in
        WorkItemCard(item: item)
      }
    }
  }
}

private struct LauncherTile: View {
  let item: NowLauncherItem
  let action: () -> Void

  private var color: Color {
    switch item.tint {
    case .itsm: return BankTheme.Palette.attention
    case .spm: return BankTheme.Palette.secure
    case .none: return BankTheme.Palette.brandRed
    }
  }

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.sm) {
        IconBubble(
          symbolName: item.symbolName,
          color: color,
          size: BankTheme.Size.compactIconBubble
        )

        Spacer(minLength: BankTheme.Spacing.xs)

        Text(item.department.uppercased())
          .font(BankTheme.Typography.caption)
          .foregroundColor(color)

        Text(item.title)
          .font(BankTheme.Typography.headline)
          .foregroundColor(BankTheme.Palette.ink)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
          .minimumScaleFactor(0.84)

        Text(item.subtitle)
          .font(BankTheme.Typography.caption)
          .foregroundColor(BankTheme.Palette.secondaryInk)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
      }
      .frame(width: 158, height: 168, alignment: .leading)
      .padding(BankTheme.Spacing.md)
      .background(
        RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
          .fill(BankTheme.Palette.surface)
          .overlay(
            RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
              .stroke(BankTheme.Palette.divider, lineWidth: BankTheme.Stroke.hairline)
          )
      )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(Text(item.title))
    .accessibilityHint(Text(item.subtitle))
  }
}

private struct ActionItemCard: View {
  let item: NowActionItem
  let action: () -> Void

  private var riskColor: Color {
    item.riskLevel == "Alto" ? BankTheme.Palette.warning : BankTheme.Palette.attention
  }

  var body: some View {
    VisualCard {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.md) {
        HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
          IconBubble(
            symbolName: "checklist.checked",
            color: riskColor,
            size: BankTheme.Size.compactIconBubble
          )

          VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
            Text(item.id)
              .font(BankTheme.Typography.caption)
              .foregroundColor(BankTheme.Palette.mutedInk)

            Text(item.title)
              .font(BankTheme.Typography.headline)
              .foregroundColor(BankTheme.Palette.ink)
              .fixedSize(horizontal: false, vertical: true)

            Text(item.requester)
              .font(BankTheme.Typography.caption)
              .foregroundColor(BankTheme.Palette.secondaryInk)
          }

          Spacer(minLength: BankTheme.Spacing.sm)

          StatusBadge(title: item.riskLevel, color: riskColor, symbolName: "flag.fill")
        }

        Text(item.detail)
          .font(BankTheme.Typography.body)
          .foregroundColor(BankTheme.Palette.secondaryInk)
          .fixedSize(horizontal: false, vertical: true)

        HStack(spacing: BankTheme.Spacing.md) {
          Label(item.due, systemImage: "clock.fill")
            .font(BankTheme.Typography.caption)
            .foregroundColor(BankTheme.Palette.secondaryInk)

          Spacer(minLength: BankTheme.Spacing.sm)

          Button(action: action) {
            Label(item.actionLabel, systemImage: "arrow.up.right.circle.fill")
          }
          .buttonStyle(.bankSecondary)
          .frame(maxWidth: 148)
        }
      }
    }
  }
}

private struct WorkItemCard: View {
  let item: NowWorkItem

  private var accentColor: Color {
    switch item.domain {
    case .itsm:
      if item.priority == "P1" { return BankTheme.Palette.warning }
      return BankTheme.Palette.attention
    case .spm:
      if item.category == "Risco" { return BankTheme.Palette.warning }
      return BankTheme.Palette.secure
    }
  }

  private var symbolName: String {
    switch item.category {
    case "Incidente": return "exclamationmark.triangle.fill"
    case "Requisição": return "shippingbox.fill"
    case "Mudança": return "arrow.triangle.2.circlepath.circle.fill"
    case "Demanda": return "lightbulb.max.fill"
    case "Projeto": return "chart.bar.doc.horizontal.fill"
    case "Risco": return "shield.slash.fill"
    default: return "rectangle.stack.fill"
    }
  }

  var body: some View {
    VisualCard {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.md) {
        HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
          IconBubble(
            symbolName: symbolName,
            color: accentColor,
            size: BankTheme.Size.compactIconBubble
          )

          VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
            Text(item.category.uppercased())
              .font(BankTheme.Typography.caption)
              .foregroundColor(accentColor)

            Text(item.title)
              .font(BankTheme.Typography.headline)
              .foregroundColor(BankTheme.Palette.ink)
              .fixedSize(horizontal: false, vertical: true)

            Text(item.id)
              .font(BankTheme.Typography.caption)
              .foregroundColor(BankTheme.Palette.mutedInk)
          }

          Spacer(minLength: BankTheme.Spacing.sm)

          StatusBadge(
            title: item.status,
            color: accentColor,
            symbolName: "circle.fill"
          )
        }

        Text(item.summary)
          .font(BankTheme.Typography.body)
          .foregroundColor(BankTheme.Palette.secondaryInk)
          .fixedSize(horizontal: false, vertical: true)

        Divider()

        HStack(spacing: BankTheme.Spacing.sm) {
          WorkItemMeta(title: item.owner, symbolName: "person.2.fill")
          WorkItemMeta(title: item.due, symbolName: "clock.fill")
          WorkItemMeta(title: item.priority, symbolName: "flag.fill")
        }

        HStack(alignment: .top, spacing: BankTheme.Spacing.sm) {
          Image(systemName: "sparkles")
            .font(BankTheme.Typography.callout)
            .foregroundColor(BankTheme.Palette.gold)

          Text(item.signal)
            .font(BankTheme.Typography.caption)
            .foregroundColor(BankTheme.Palette.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BankTheme.Spacing.sm)
        .background(
          RoundedRectangle(cornerRadius: BankTheme.Radius.sm, style: .continuous)
            .fill(BankTheme.Palette.gold.opacity(0.10))
        )
      }
    }
  }
}

private struct WorkItemMeta: View {
  let title: String
  let symbolName: String

  var body: some View {
    Label {
      Text(title)
        .lineLimit(1)
        .minimumScaleFactor(0.72)
    } icon: {
      Image(systemName: symbolName)
    }
    .font(BankTheme.Typography.caption)
    .foregroundColor(BankTheme.Palette.secondaryInk)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
