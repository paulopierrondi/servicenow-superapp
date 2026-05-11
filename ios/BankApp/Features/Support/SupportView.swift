import SwiftUI

struct SupportView: View {
  @EnvironmentObject private var authSession: AuthSession

  @State private var messages: [NowAssistMessage] = NowAssistMessage.initialMessages
  @State private var draft = ""
  @State private var isSending = false
  @State private var managerHandoffPrepared = false
  @State private var workflowPublished = ProcessInfo.processInfo.arguments.contains(
    "-BankAppDemoApproved")

  private let nowAssistClient = NowAssistClient()

  private var isDemoConversation: Bool {
    ProcessInfo.processInfo.arguments.contains("-BankAppDemoConversation")
  }

  private var assistEndpointStatus: String {
    AppEnvironment.serviceNowInstanceURL == nil ? "fallback local" : "instância conectada"
  }

  var body: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(spacing: BankTheme.Spacing.xl) {
            header
            if isDemoConversation {
              chat
              assistantStatus
              agenticExposure
            } else {
              assistantStatus
              agenticExposure
              chat
            }
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
            color: BankTheme.Palette.brandRed,
            size: BankTheme.Size.iconBubble
          )

          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            Text("Mordomo ServiceNow")
              .font(BankTheme.Typography.section)
              .foregroundColor(.white)

            Text(
              "O chat tenta usar /api/x_bank/v1/mobile-assist na instância. Quando Virtual Agent API + Now Assist estiverem ativos, este gateway troca para o canal nativo sem mudar o app."
            )
            .font(BankTheme.Typography.body)
            .foregroundColor(.white.opacity(0.84))
            .fixedSize(horizontal: false, vertical: true)
          }
        }

        HStack(spacing: BankTheme.Spacing.sm) {
          StatusBadge(
            title: assistEndpointStatus,
            color: BankTheme.Palette.success,
            symbolName: "network"
          )

          StatusBadge(
            title: "sem PII em log",
            color: BankTheme.Palette.attention,
            symbolName: "lock.doc.fill"
          )
        }
      }
    }
  }

  private var agenticExposure: some View {
    let workflow = AutonomousWorkflowResponse.demo

    return VisualCard {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.md) {
        HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
          IconBubble(
            symbolName: "point.3.connected.trianglepath.dotted",
            color: BankTheme.Palette.brandAction,
            size: BankTheme.Size.compactIconBubble
          )

          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            Text("Agentic workflow exposto")
              .font(BankTheme.Typography.headline)
              .foregroundColor(BankTheme.Palette.ink)

            Text(workflow.run.title)
              .font(BankTheme.Typography.body)
              .foregroundColor(BankTheme.Palette.secondaryInk)
              .fixedSize(horizontal: false, vertical: true)
          }

          Spacer(minLength: BankTheme.Spacing.sm)

          StatusBadge(
            title: workflowPublished ? "na instância" : "rascunho",
            color: workflowPublished ? BankTheme.Palette.success : BankTheme.Palette.warning,
            symbolName: workflowPublished ? "checkmark.seal.fill" : "doc.badge.gearshape.fill"
          )
        }

        HStack(spacing: BankTheme.Spacing.sm) {
          AgenticMiniMetric(value: workflow.run.severity, title: "Severidade")
          AgenticMiniMetric(value: "\(workflow.agents.count)", title: "AI specialists")
          AgenticMiniMetric(value: workflow.run.businessImpact, title: "Impacto")
        }

        Button {
          workflowPublished.toggle()
          if workflowPublished {
            messages.append(
              NowAssistMessage(
                id: UUID(),
                role: .assistant,
                text:
                  "Run \(workflow.run.id) exposto como trilha demo: incidente/change/case, CMDB, citações e guardrails prontos para revisão na instância.",
                timestamp: Date()
              )
            )
          }
        } label: {
          Label(
            workflowPublished ? "Workflow publicado" : "Publicar plano na instância",
            systemImage: workflowPublished ? "checkmark.seal.fill" : "arrow.up.doc.fill"
          )
        }
        .buttonStyle(.bankPrimary)
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
              .font(BankTheme.Typography.body)
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
                    .fill(BankTheme.Palette.brandAction)
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

private struct AgenticMiniMetric: View {
  let value: String
  let title: String

  var body: some View {
    VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
      Text(value)
        .font(BankTheme.Typography.caption)
        .foregroundColor(BankTheme.Palette.ink)
        .lineLimit(1)
        .minimumScaleFactor(0.74)

      Text(title)
        .font(BankTheme.Typography.micro)
        .foregroundColor(BankTheme.Palette.secondaryInk)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(BankTheme.Spacing.sm)
    .background(
      RoundedRectangle(cornerRadius: BankTheme.Radius.sm, style: .continuous)
        .fill(BankTheme.Palette.subtleSurface)
    )
  }
}
