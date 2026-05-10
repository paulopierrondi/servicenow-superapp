import SwiftUI

struct AppBackground<Content: View>: View {
  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    ZStack {
      BankTheme.Palette.appBackground.ignoresSafeArea()
      content
    }
  }
}

struct VisualCard<Content: View>: View {
  private let content: Content
  private let fill: Color

  init(fill: Color = BankTheme.Palette.surface, @ViewBuilder content: () -> Content) {
    self.fill = fill
    self.content = content()
  }

  var body: some View {
    content
      .padding(BankTheme.Spacing.md)
      .background(
        RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
          .fill(fill)
          .overlay(
            RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
              .stroke(
                BankTheme.Palette.divider.opacity(0.54),
                lineWidth: BankTheme.Stroke.hairline
              )
          )
      )
      .shadow(color: Color.black.opacity(0.055), radius: 18, x: 0, y: 9)
  }
}

struct SectionHeader: View {
  let titleKey: LocalizedStringKey
  let actionKey: LocalizedStringKey?
  let action: (() -> Void)?

  init(
    _ titleKey: LocalizedStringKey,
    actionKey: LocalizedStringKey? = nil,
    action: (() -> Void)? = nil
  ) {
    self.titleKey = titleKey
    self.actionKey = actionKey
    self.action = action
  }

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(titleKey)
        .font(BankTheme.Typography.section)
        .foregroundColor(BankTheme.Palette.ink)

      Spacer(minLength: BankTheme.Spacing.sm)

      if let actionKey, let action {
        Button(action: action) {
          Text(actionKey)
            .font(BankTheme.Typography.callout)
        }
        .buttonStyle(.plain)
        .foregroundColor(BankTheme.Palette.brandAction)
      }
    }
    .accessibilityElement(children: .combine)
  }
}

struct IconBubble: View {
  let symbolName: String
  let color: Color
  let size: CGFloat

  init(
    symbolName: String,
    color: Color = BankTheme.Palette.brandRed,
    size: CGFloat = BankTheme.Size.iconBubble
  ) {
    self.symbolName = symbolName
    self.color = color
    self.size = size
  }

  var body: some View {
    ZStack {
      Circle()
        .fill(color.opacity(0.14))

      Image(systemName: symbolName)
        .font(.system(size: size * 0.38, weight: .semibold, design: .default))
        .foregroundColor(color)
    }
    .frame(width: size, height: size)
  }
}

struct StatusBadge: View {
  private let title: Text
  let color: Color
  let symbolName: String

  init(titleKey: LocalizedStringKey, color: Color, symbolName: String) {
    title = Text(titleKey)
    self.color = color
    self.symbolName = symbolName
  }

  init(title: String, color: Color, symbolName: String) {
    self.title = Text(title)
    self.color = color
    self.symbolName = symbolName
  }

  var body: some View {
    Label {
      title
        .font(BankTheme.Typography.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.9)
    } icon: {
      Image(systemName: symbolName)
        .font(BankTheme.Typography.caption)
    }
    .padding(.horizontal, BankTheme.Spacing.sm)
    .padding(.vertical, BankTheme.Spacing.xs)
    .foregroundColor(color)
    .background(
      Capsule(style: .continuous)
        .fill(color.opacity(0.12))
    )
  }
}

struct MetricPill: View {
  let value: String
  let titleKey: LocalizedStringKey
  let symbolName: String
  let color: Color

  var body: some View {
    HStack(spacing: BankTheme.Spacing.sm) {
      IconBubble(
        symbolName: symbolName,
        color: color,
        size: BankTheme.Size.compactIconBubble
      )

      VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
        Text(value)
          .font(BankTheme.Typography.metric)
          .foregroundColor(BankTheme.Palette.ink)
          .lineLimit(1)
          .minimumScaleFactor(0.86)

        Text(titleKey)
          .font(BankTheme.Typography.caption)
          .foregroundColor(BankTheme.Palette.secondaryInk)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(BankTheme.Spacing.md)
    .background(
      RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
        .fill(BankTheme.Palette.elevatedSurface)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
    )
  }
}

struct CMDBHealthPanel: View {
  private let metrics = [
    CMDBHealthMetric(title: "Completeness", value: "92%", color: BankTheme.Palette.success),
    CMDBHealthMetric(title: "Correctness", value: "88%", color: BankTheme.Palette.warning),
    CMDBHealthMetric(title: "Compliance", value: "95%", color: BankTheme.Palette.attention),
    CMDBHealthMetric(title: "Relations", value: "84%", color: BankTheme.Palette.brandSecondary),
  ]

  let title: String
  let subtitle: String
  let score: Int

  init(
    title: String = "CMDB Health",
    subtitle: String = "Serviços, CIs e dependências críticas conectados ao fluxo mobile.",
    score: Int = 91
  ) {
    self.title = title
    self.subtitle = subtitle
    self.score = score
  }

  var body: some View {
    let columns = Array(
      repeating: GridItem(.flexible(), spacing: BankTheme.Spacing.sm),
      count: 2
    )

    VisualCard {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.md) {
        HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
          CMDBHealthScoreRing(score: score)

          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            Text(title)
              .font(BankTheme.Typography.section)
              .foregroundColor(BankTheme.Palette.ink)

            Text(subtitle)
              .font(BankTheme.Typography.callout)
              .foregroundColor(BankTheme.Palette.secondaryInk)
              .fixedSize(horizontal: false, vertical: true)

            StatusBadge(
              title: "Service Graph ativo",
              color: BankTheme.Palette.brandAction,
              symbolName: "point.3.connected.trianglepath.dotted"
            )
          }
        }

        LazyVGrid(columns: columns, spacing: BankTheme.Spacing.sm) {
          ForEach(metrics) { metric in
            CMDBHealthMetricTile(metric: metric)
          }
        }

        HStack(spacing: BankTheme.Spacing.sm) {
          CMDBRemediationPill(title: "18 CIs stale", symbolName: "clock.badge.exclamationmark")
          CMDBRemediationPill(title: "7 relações órfãs", symbolName: "link.badge.plus")
        }
      }
    }
  }
}

private struct CMDBHealthMetric: Identifiable {
  let id = UUID()
  let title: String
  let value: String
  let color: Color
}

private struct CMDBHealthScoreRing: View {
  let score: Int

  private var progress: Double {
    min(max(Double(score) / 100, 0), 1)
  }

  var body: some View {
    ZStack {
      Circle()
        .stroke(BankTheme.Palette.divider.opacity(0.7), lineWidth: 8)

      Circle()
        .trim(from: 0, to: progress)
        .stroke(
          BankTheme.Palette.brandAction,
          style: StrokeStyle(lineWidth: 8, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))

      VStack(spacing: 0) {
        Text("\(score)")
          .font(BankTheme.Typography.metric)
          .foregroundColor(BankTheme.Palette.ink)

        Text("score")
          .font(BankTheme.Typography.micro)
          .foregroundColor(BankTheme.Palette.secondaryInk)
      }
    }
    .frame(width: 88, height: 88)
    .accessibilityElement(children: .combine)
  }
}

private struct CMDBHealthMetricTile: View {
  let metric: CMDBHealthMetric

  var body: some View {
    HStack(spacing: BankTheme.Spacing.sm) {
      Circle()
        .fill(metric.color)
        .frame(width: 10, height: 10)

      VStack(alignment: .leading, spacing: 0) {
        Text(metric.value)
          .font(BankTheme.Typography.headline)
          .foregroundColor(BankTheme.Palette.ink)

        Text(metric.title)
          .font(BankTheme.Typography.caption)
          .foregroundColor(BankTheme.Palette.secondaryInk)
      }

      Spacer(minLength: 0)
    }
    .padding(BankTheme.Spacing.sm)
    .background(
      RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
        .fill(BankTheme.Palette.subtleSurface)
    )
  }
}

private struct CMDBRemediationPill: View {
  let title: String
  let symbolName: String

  var body: some View {
    Label(title, systemImage: symbolName)
      .font(BankTheme.Typography.caption)
      .foregroundColor(BankTheme.Palette.secondaryInk)
      .lineLimit(1)
      .minimumScaleFactor(0.9)
      .frame(maxWidth: .infinity)
      .padding(.vertical, BankTheme.Spacing.sm)
      .background(
        Capsule(style: .continuous)
          .fill(BankTheme.Palette.appBackground)
      )
  }
}

struct ActionTile: View {
  let title: String
  let subtitle: String
  let symbolName: String
  let color: Color
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.sm) {
        IconBubble(
          symbolName: symbolName,
          color: color,
          size: BankTheme.Size.compactIconBubble
        )

        Spacer(minLength: BankTheme.Spacing.xs)

        Text(title)
          .font(BankTheme.Typography.headline)
          .foregroundColor(BankTheme.Palette.ink)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
          .minimumScaleFactor(0.84)

        Text(subtitle)
          .font(BankTheme.Typography.callout)
          .foregroundColor(BankTheme.Palette.secondaryInk)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
      }
      .frame(maxWidth: .infinity, minHeight: BankTheme.Size.actionTileHeight, alignment: .leading)
      .padding(BankTheme.Spacing.md)
      .background(
        RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
          .fill(BankTheme.Palette.surface)
          .overlay(
            RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
              .stroke(BankTheme.Palette.divider.opacity(0.72), lineWidth: BankTheme.Stroke.hairline)
          )
          .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 6)
      )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(Text(title))
    .accessibilityHint(Text(subtitle))
  }
}

struct BankPrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(BankTheme.Typography.headline)
      .foregroundColor(.white)
      .frame(maxWidth: .infinity)
      .padding(.vertical, BankTheme.Spacing.md)
      .background(
        RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
          .fill(BankTheme.Palette.brandAction)
          .opacity(configuration.isPressed ? 0.72 : 1)
      )
  }
}

struct BankSecondaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(BankTheme.Typography.headline)
      .foregroundColor(BankTheme.Palette.brandAction)
      .frame(maxWidth: .infinity)
      .padding(.vertical, BankTheme.Spacing.md)
      .background(
        RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
          .fill(BankTheme.Palette.brandAction.opacity(configuration.isPressed ? 0.18 : 0.10))
      )
  }
}

extension ButtonStyle where Self == BankPrimaryButtonStyle {
  static var bankPrimary: BankPrimaryButtonStyle { BankPrimaryButtonStyle() }
}

extension ButtonStyle where Self == BankSecondaryButtonStyle {
  static var bankSecondary: BankSecondaryButtonStyle { BankSecondaryButtonStyle() }
}
