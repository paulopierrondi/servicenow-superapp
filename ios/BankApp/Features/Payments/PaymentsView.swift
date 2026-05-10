import SwiftUI

private enum PaymentMode: String, CaseIterable, Identifiable {
  case pix
  case boleto
  case card
  case transfer

  var id: String { rawValue }

  var titleKey: LocalizedStringKey {
    switch self {
    case .pix: return "payments.mode.pix"
    case .boleto: return "payments.mode.boleto"
    case .card: return "payments.mode.card"
    case .transfer: return "payments.mode.transfer"
    }
  }

  var symbolName: String {
    switch self {
    case .pix: return "qrcode.viewfinder"
    case .boleto: return "barcode.viewfinder"
    case .card: return "creditcard.fill"
    case .transfer: return "arrow.left.arrow.right.circle.fill"
    }
  }
}

struct PaymentsView: View {
  @State private var mode: PaymentMode = .pix
  @State private var recipient = ""
  @State private var amount = ""
  @State private var scheduledDate = Date()
  @State private var saveFavorite = true
  @State private var requireBiometry = true
  @State private var receiptRequested = true

  private var canSubmit: Bool {
    recipient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
      && amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
  }

  var body: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(spacing: BankTheme.Spacing.xl) {
            header
            paymentComposer
            scheduledPayments
            paymentTools
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
      Text("payments.eyebrow")
        .font(BankTheme.Typography.caption)
        .foregroundColor(BankTheme.Palette.brandRed)

      Text("payments.title")
        .font(BankTheme.Typography.title)
        .foregroundColor(BankTheme.Palette.ink)

      Text("payments.subtitle")
        .font(BankTheme.Typography.body)
        .foregroundColor(BankTheme.Palette.secondaryInk)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var paymentComposer: some View {
    VisualCard {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.lg) {
        Picker("payments.mode.selector", selection: $mode) {
          ForEach(PaymentMode.allCases) { item in
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

            Text("payments.composer.detail")
              .font(BankTheme.Typography.caption)
              .foregroundColor(BankTheme.Palette.secondaryInk)
          }
        }

        VStack(spacing: BankTheme.Spacing.md) {
          TextField("payments.recipient.placeholder", text: $recipient)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .padding(BankTheme.Spacing.md)
            .background(inputBackground)

          TextField("payments.amount.placeholder", text: $amount)
            .keyboardType(.decimalPad)
            .padding(BankTheme.Spacing.md)
            .background(inputBackground)

          DatePicker(
            "payments.date.label",
            selection: $scheduledDate,
            displayedComponents: .date
          )
          .font(BankTheme.Typography.body)
          .foregroundColor(BankTheme.Palette.ink)
        }

        VStack(spacing: BankTheme.Spacing.sm) {
          Toggle("payments.option.favorite", isOn: $saveFavorite)
          Toggle("payments.option.biometry", isOn: $requireBiometry)
          Toggle("payments.option.receipt", isOn: $receiptRequested)
        }
        .font(BankTheme.Typography.body)
        .tint(BankTheme.Palette.brandRed)

        Button {
          recipient = ""
          amount = ""
        } label: {
          Label("payments.submit", systemImage: "lock.shield.fill")
        }
        .buttonStyle(.bankPrimary)
        .disabled(canSubmit == false)
        .opacity(canSubmit ? 1 : 0.48)
        .accessibilityHint(Text("payments.submit.hint"))
      }
    }
  }

  private var scheduledPayments: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("payments.scheduled.title", actionKey: "common.manage") {}

      VisualCard {
        VStack(spacing: BankTheme.Spacing.md) {
          ForEach(ScheduledPayment.demo) { payment in
            HStack(spacing: BankTheme.Spacing.md) {
              IconBubble(
                symbolName: "calendar.badge.clock",
                color: BankTheme.Palette.attention,
                size: BankTheme.Size.compactIconBubble
              )

              VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
                Text(payment.title)
                  .font(BankTheme.Typography.headline)
                  .foregroundColor(BankTheme.Palette.ink)

                Text(payment.dueDate)
                  .font(BankTheme.Typography.caption)
                  .foregroundColor(BankTheme.Palette.secondaryInk)
              }

              Spacer(minLength: BankTheme.Spacing.sm)

              VStack(alignment: .trailing, spacing: BankTheme.Spacing.xxs) {
                Text(MoneyFormatter.string(from: payment.amount))
                  .font(BankTheme.Typography.callout)
                  .foregroundColor(BankTheme.Palette.ink)

                Text(payment.status)
                  .font(BankTheme.Typography.caption)
                  .foregroundColor(BankTheme.Palette.success)
              }
            }
          }
        }
      }
    }
  }

  private var paymentTools: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("payments.tools.title")

      HStack(spacing: BankTheme.Spacing.md) {
        MetricPill(
          value: "18s",
          titleKey: "payments.metric.pix",
          symbolName: "bolt.fill",
          color: BankTheme.Palette.warning
        )

        MetricPill(
          value: "R$ 32,5k",
          titleKey: "payments.metric.limit",
          symbolName: "creditcard.fill",
          color: BankTheme.Palette.gold
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
