import SwiftUI

struct BrandSelectionView: View {
  @EnvironmentObject private var brandStore: BrandStore

  var body: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(alignment: .leading, spacing: BankTheme.Spacing.xl) {
            header
            brandChoices
            experienceStrip
          }
          .padding(.horizontal, BankTheme.Spacing.lg)
          .padding(.vertical, BankTheme.Spacing.xxxl)
        }
      }
      .navigationBarHidden(true)
    }
    .navigationViewStyle(.stack)
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: BankTheme.Spacing.sm) {
      Text("brand.selection.eyebrow")
        .font(BankTheme.Typography.caption)
        .foregroundColor(BankTheme.Palette.brandRed)

      Text("brand.selection.title")
        .font(BankTheme.Typography.display)
        .foregroundColor(BankTheme.Palette.ink)
        .fixedSize(horizontal: false, vertical: true)

      Text("brand.selection.subtitle")
        .font(BankTheme.Typography.body)
        .foregroundColor(BankTheme.Palette.secondaryInk)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var brandChoices: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      ForEach(AppBrand.allCases, id: \.rawValue) { brand in
        BrandChoiceButton(brand: brand) {
          withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            brandStore.select(brand)
          }
        }
      }
    }
  }

  private var experienceStrip: some View {
    HStack(spacing: BankTheme.Spacing.sm) {
      ExperiencePill(title: "ITSM", symbolName: "wrench.and.screwdriver.fill")
      ExperiencePill(title: "SPM", symbolName: "chart.line.uptrend.xyaxis")
      ExperiencePill(title: "CSM + CRM", symbolName: "person.2.fill")
    }
  }
}

private struct BrandChoiceButton: View {
  let brand: AppBrand
  let action: () -> Void

  private var detailKey: LocalizedStringKey {
    switch brand {
    case .bradesco: return "brand.selection.bradesco.detail"
    case .itau: return "brand.selection.itau.detail"
    }
  }

  private var callToAction: String {
    String(
      format: NSLocalizedString(
        "brand.selection.continue.format", comment: "REVISÃO PT-BR HUMANA OBRIGATÓRIA"),
      brand.displayName)
  }

  var body: some View {
    Button(action: action) {
      HStack(spacing: BankTheme.Spacing.md) {
        ZStack {
          RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
            .fill(brand.primaryColor)

          Text(brand == .bradesco ? "B" : "I")
            .font(.system(size: 28, weight: .heavy, design: .default))
            .foregroundColor(.white)
        }
        .frame(width: 62, height: 62)

        VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
          Text(brand.displayName)
            .font(BankTheme.Typography.section)
            .foregroundColor(BankTheme.Palette.ink)

          Text(detailKey)
            .font(BankTheme.Typography.callout)
            .foregroundColor(BankTheme.Palette.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)

          Label(callToAction, systemImage: "arrow.right.circle.fill")
            .font(BankTheme.Typography.callout)
            .foregroundColor(brand.primaryColor)
        }

        Spacer(minLength: BankTheme.Spacing.sm)
      }
      .padding(BankTheme.Spacing.md)
      .background(
        RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
          .fill(BankTheme.Palette.surface)
          .overlay(
            RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
              .stroke(brand.primaryColor.opacity(0.24), lineWidth: BankTheme.Stroke.hairline)
          )
      )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(Text(callToAction))
  }
}

private struct ExperiencePill: View {
  let title: String
  let symbolName: String

  var body: some View {
    Label(title, systemImage: symbolName)
      .font(BankTheme.Typography.caption)
      .foregroundColor(BankTheme.Palette.secondaryInk)
      .lineLimit(1)
      .minimumScaleFactor(0.88)
      .frame(maxWidth: .infinity)
      .padding(.vertical, BankTheme.Spacing.sm)
      .background(
        Capsule(style: .continuous)
          .fill(BankTheme.Palette.surface)
      )
  }
}
