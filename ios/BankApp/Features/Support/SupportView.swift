import SwiftUI

struct SupportView: View {
  @EnvironmentObject private var authSession: AuthSession

  @State private var messages: [NowAssistMessage] = [.welcome]
  @State private var draft = ""
  @State private var isSending = false
  @State private var managerHandoffPrepared = false

  private let nowAssistClient = NowAssistClient()

  var body: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(spacing: BankTheme.Spacing.xl) {
            header
            assistantStatus
            chat
            managerHandoff
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
      Text("support.eyebrow")
        .font(BankTheme.Typography.caption)
        .foregroundColor(BankTheme.Palette.brandRed)

      Text("support.title")
        .font(BankTheme.Typography.title)
        .foregroundColor(BankTheme.Palette.ink)

      Text("support.subtitle")
        .font(BankTheme.Typography.body)
        .foregroundColor(BankTheme.Palette.secondaryInk)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var assistantStatus: some View {
    VisualCard(fill: BankTheme.Palette.graphite) {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.md) {
        HStack(spacing: BankTheme.Spacing.md) {
          IconBubble(
            symbolName: "sparkles",
            color: BankTheme.Palette.gold,
            size: BankTheme.Size.iconBubble
          )

          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            Text("support.nowassist.title")
              .font(BankTheme.Typography.section)
              .foregroundColor(.white)

            Text("support.nowassist.detail")
              .font(BankTheme.Typography.body)
              .foregroundColor(.white.opacity(0.72))
              .fixedSize(horizontal: false, vertical: true)
          }
        }

        HStack(spacing: BankTheme.Spacing.sm) {
          StatusBadge(
            titleKey: "support.badge.context",
            color: BankTheme.Palette.success,
            symbolName: "checkmark.seal.fill"
          )

          StatusBadge(
            titleKey: "support.badge.audit",
            color: BankTheme.Palette.attention,
            symbolName: "lock.doc.fill"
          )
        }
      }
    }
  }

  private var chat: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("support.chat.title")

      VisualCard {
        VStack(spacing: BankTheme.Spacing.md) {
          ForEach(messages) { message in
            MessageBubble(message: message)
          }

          HStack(spacing: BankTheme.Spacing.sm) {
            TextField("support.chat.placeholder", text: $draft)
              .textInputAutocapitalization(.sentences)
              .padding(BankTheme.Spacing.md)
              .background(
                RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
                  .fill(BankTheme.Palette.appBackground)
              )

            Button {
              Task { await sendMessage() }
            } label: {
              Image(systemName: isSending ? "hourglass" : "paperplane.fill")
                .frame(width: BankTheme.Size.iconButton, height: BankTheme.Size.iconButton)
                .background(
                  Circle()
                    .fill(BankTheme.Palette.brandRed)
                )
                .foregroundColor(.white)
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            .accessibilityLabel(Text("support.chat.send"))
          }
        }
      }
    }
  }

  private var managerHandoff: some View {
    VisualCard {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.md) {
        HStack(spacing: BankTheme.Spacing.md) {
          IconBubble(
            symbolName: "person.crop.circle.badge.questionmark.fill",
            color: BankTheme.Palette.brandRed,
            size: BankTheme.Size.compactIconBubble
          )

          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            Text("support.manager.title")
              .font(BankTheme.Typography.headline)
              .foregroundColor(BankTheme.Palette.ink)

            Text(
              String(
                format: NSLocalizedString(
                  "support.manager.detail.format", comment: "REVISÃO PT-BR HUMANA OBRIGATÓRIA"),
                authSession.user.relationshipManager)
            )
            .font(BankTheme.Typography.body)
            .foregroundColor(BankTheme.Palette.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)
          }
        }

        Button {
          managerHandoffPrepared.toggle()
        } label: {
          Label(
            managerHandoffPrepared ? "support.manager.ready" : "support.manager.prepare",
            systemImage: managerHandoffPrepared
              ? "checkmark.seal.fill" : "arrow.triangle.turn.up.right.circle.fill"
          )
        }
        .buttonStyle(.bankPrimary)
      }
    }
  }

  private func sendMessage() async {
    let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isEmpty == false else { return }

    isSending = true
    draft = ""
    messages.append(NowAssistMessage(id: UUID(), role: .user, text: trimmed, timestamp: Date()))
    let reply = await nowAssistClient.send(trimmed)
    messages.append(reply)
    isSending = false
  }
}

private struct MessageBubble: View {
  let message: NowAssistMessage

  private var alignment: HorizontalAlignment {
    message.role == .user ? .trailing : .leading
  }

  private var bubbleColor: Color {
    message.role == .user ? BankTheme.Palette.brandRed : BankTheme.Palette.appBackground
  }

  private var textColor: Color {
    message.role == .user ? .white : BankTheme.Palette.ink
  }

  var body: some View {
    VStack(alignment: alignment, spacing: BankTheme.Spacing.xxs) {
      Text(message.text)
        .font(BankTheme.Typography.body)
        .foregroundColor(textColor)
        .padding(BankTheme.Spacing.md)
        .background(
          RoundedRectangle(cornerRadius: BankTheme.Radius.lg, style: .continuous)
            .fill(bubbleColor)
        )
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)

      Text(message.role == .user ? "support.chat.you" : "support.chat.assistant")
        .font(BankTheme.Typography.caption)
        .foregroundColor(BankTheme.Palette.mutedInk)
    }
    .accessibilityElement(children: .combine)
  }
}
