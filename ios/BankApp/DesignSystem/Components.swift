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
              .stroke(BankTheme.Palette.divider, lineWidth: BankTheme.Stroke.hairline)
          )
      )
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
        .foregroundColor(BankTheme.Palette.brandRed)
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
        .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
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
          .minimumScaleFactor(0.72)

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
          .font(BankTheme.Typography.caption)
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
              .stroke(BankTheme.Palette.divider, lineWidth: BankTheme.Stroke.hairline)
          )
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
          .fill(BankTheme.Palette.brandRed)
          .opacity(configuration.isPressed ? 0.72 : 1)
      )
  }
}

struct BankSecondaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(BankTheme.Typography.headline)
      .foregroundColor(BankTheme.Palette.brandRed)
      .frame(maxWidth: .infinity)
      .padding(.vertical, BankTheme.Spacing.md)
      .background(
        RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
          .fill(BankTheme.Palette.brandRed.opacity(configuration.isPressed ? 0.18 : 0.10))
      )
  }
}

extension ButtonStyle where Self == BankPrimaryButtonStyle {
  static var bankPrimary: BankPrimaryButtonStyle { BankPrimaryButtonStyle() }
}

extension ButtonStyle where Self == BankSecondaryButtonStyle {
  static var bankSecondary: BankSecondaryButtonStyle { BankSecondaryButtonStyle() }
}
