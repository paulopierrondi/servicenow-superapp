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
  @EnvironmentObject private var brandStore: BrandStore

  @Binding var selectedTab: AppTab

  @State private var workspace: NowWorkspace = .itsm
  @State private var searchText = ""
  @State private var voiceModeEnabled = false
  @State private var offlineQueueEnabled = true
  @State private var activeTwinIndex = 0
  @State private var emergencyChangeApproved = ProcessInfo.processInfo.arguments.contains(
    "-BankAppDemoApproved")
  @State private var incidentBridgeOpened = ProcessInfo.processInfo.arguments.contains(
    "-BankAppDemoApproved")
  @State private var executiveRequestReleased = ProcessInfo.processInfo.arguments.contains(
    "-BankAppDemoApproved")
  @State private var autonomousRunStarted = ProcessInfo.processInfo.arguments.contains(
    "-BankAppDemoApproved")
  @State private var autonomousHumanApproved = ProcessInfo.processInfo.arguments.contains(
    "-BankAppDemoApproved")

  private var workItems: [NowWorkItem] {
    switch workspace {
    case .itsm: return NowWorkItem.demoITSM
    case .spm: return NowWorkItem.demoSPM
    }
  }

  private var customerExperienceItems: [CustomerExperienceItem] {
    CustomerExperienceItem.bankingDemo()
  }

  private var isItau: Bool {
    AppBrand.current == .itau
  }

  private var criticalSeverity: String {
    isItau ? "P0" : "P1"
  }

  private var criticalServiceName: String {
    isItau ? "Core Pix Personnalité" : "Pix Prime mobile"
  }

  private var autonomousWorkflow: AutonomousWorkflowResponse {
    .demo
  }

  var body: some View {
    NavigationView {
      AppBackground {
        ScrollView(showsIndicators: false) {
          VStack(spacing: BankTheme.Spacing.xl) {
            header
            executiveDecisionCenter
            autonomousWorkforcePanel
            journeyTwin
            CMDBHealthPanel(
              title: "CMDB Health do dia",
              subtitle: "Saúde por serviço, CIs, dependências e relações antes de qualquer decisão."
            )
            universalSearch
            assistantPanel
            launcher
            actionInbox
            knowledgeAnswer
            customerExperienceCenter
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
    HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
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

      Spacer(minLength: BankTheme.Spacing.sm)

      Button {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
          brandStore.resetSelection()
        }
      } label: {
        Image(systemName: "arrow.triangle.2.circlepath")
          .font(BankTheme.Typography.headline)
          .foregroundColor(BankTheme.Palette.brandAction)
          .frame(width: BankTheme.Size.iconButton, height: BankTheme.Size.iconButton)
          .background(
            Circle()
              .fill(BankTheme.Palette.surface)
          )
      }
      .accessibilityLabel(Text("brand.switch"))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var executiveDecisionCenter: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("Mesa executiva ServiceNow", actionKey: "Perguntar ao Assist") {
        selectedTab = .support
      }

      VisualCard(fill: BankTheme.Palette.graphite) {
        VStack(alignment: .leading, spacing: BankTheme.Spacing.lg) {
          HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
              Text("\(criticalSeverity) • \(criticalServiceName)")
                .font(BankTheme.Typography.caption)
                .foregroundColor(BankTheme.Palette.warning)

              Text("Decisões que movem ITSM, CSM, CRM e SPM")
                .font(BankTheme.Typography.section)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

              Text(
                "Aprovação, ponte técnica e pedido executivo compartilham CMDB, SLA, cliente afetado, rollback e trilha de auditoria."
              )
              .font(BankTheme.Typography.callout)
              .foregroundColor(.white.opacity(0.76))
              .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: BankTheme.Spacing.sm)

            ExecutivePulseRing(
              value: emergencyChangeApproved && incidentBridgeOpened ? 0.92 : 0.64,
              color: emergencyChangeApproved && incidentBridgeOpened
                ? BankTheme.Palette.success : BankTheme.Palette.warning
            )
            .frame(width: 82, height: 82)
          }

          VStack(spacing: BankTheme.Spacing.sm) {
            NowDecisionActionRow(
              title: isItau ? "Aprovar CHG004102" : "Aprovar CHG003871",
              detail: isItau
                ? "Fix emergencial no Core Pix com rollback e evidências."
                : "Mudança no gateway Pix Prime com janela assistida.",
              symbolName: "arrow.triangle.2.circlepath.circle.fill",
              color: BankTheme.Palette.warning,
              isDone: emergencyChangeApproved,
              doneText: "Mudança aprovada"
            ) {
              withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                emergencyChangeApproved.toggle()
              }
            }

            NowDecisionActionRow(
              title: isItau ? "Abrir ponte P0" : "Assumir war room P1",
              detail: isItau
                ? "SRE, Pix, antifraude, atendimento e diretoria com contexto."
                : "Mobile, antifraude, CSM Prime e agência com uma timeline.",
              symbolName: "dot.radiowaves.left.and.right",
              color: BankTheme.Palette.attention,
              isDone: incidentBridgeOpened,
              doneText: "Ponte ativa"
            ) {
              withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                incidentBridgeOpened.toggle()
              }
            }

            NowDecisionActionRow(
              title: isItau ? "Liberar atendimento alta renda" : "Liberar playbook agência Prime",
              detail: "Catálogo cria comunicação, tarefas CSM e evidência para auditoria.",
              symbolName: "shippingbox.fill",
              color: BankTheme.Palette.brandRed,
              isDone: executiveRequestReleased,
              doneText: "Pedido em fulfillment"
            ) {
              withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                executiveRequestReleased.toggle()
              }
            }
          }

          WarRoomSignalBoard(
            isItau: isItau,
            changeApproved: emergencyChangeApproved,
            bridgeOpened: incidentBridgeOpened,
            requestReleased: executiveRequestReleased
          )
        }
      }
    }
  }

  private var journeyTwin: some View {
    JourneyTwinCard(
      twin: .demo,
      activeIndex: $activeTwinIndex
    ) {
      searchText = NowJourneyTwin.demo.title
      selectedTab = .support
    }
  }

  private var autonomousWorkforcePanel: some View {
    let workflow = autonomousWorkflow

    return VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("Autonomous Workforce", actionKey: "Expor na instância") {
        selectedTab = .support
      }

      VisualCard(fill: BankTheme.Palette.graphite) {
        VStack(alignment: .leading, spacing: BankTheme.Spacing.lg) {
          HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
              Text(workflow.controlPlane.experience.uppercased())
                .font(BankTheme.Typography.caption)
                .foregroundColor(BankTheme.Palette.brandAction)

              Text(workflow.run.title)
                .font(BankTheme.Typography.section)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

              Text(workflow.controlPlane.valueChain)
                .font(BankTheme.Typography.callout)
                .foregroundColor(.white.opacity(0.74))
            }

            Spacer(minLength: BankTheme.Spacing.sm)

            StatusBadge(
              title: autonomousHumanApproved ? "governado" : workflow.run.severity,
              color: autonomousHumanApproved
                ? BankTheme.Palette.success : BankTheme.Palette.warning,
              symbolName: autonomousHumanApproved
                ? "checkmark.shield.fill" : "exclamationmark.triangle.fill"
            )
          }

          VStack(spacing: BankTheme.Spacing.sm) {
            ForEach(workflow.run.steps) { step in
              AutonomousStepRow(
                step: step,
                isActive: autonomousRunStarted && step.id != "govern",
                isApproved: autonomousHumanApproved
              )
            }
          }

          HStack(spacing: BankTheme.Spacing.sm) {
            ForEach(workflow.agents) { agent in
              AutonomousAgentChip(agent: agent)
            }
          }

          HStack(spacing: BankTheme.Spacing.sm) {
            GovernancePill(title: "Human in the loop", isOn: workflow.governance.humanInTheLoop)
            GovernancePill(title: "Least privilege", isOn: workflow.governance.leastPrivilege)
          }

          HStack(spacing: BankTheme.Spacing.sm) {
            Button {
              withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                autonomousRunStarted.toggle()
              }
            } label: {
              Label(
                autonomousRunStarted ? "Workflow em execução" : "Iniciar execução agentic",
                systemImage: autonomousRunStarted
                  ? "dot.radiowaves.left.and.right" : "play.circle.fill"
              )
            }
            .buttonStyle(.bankSecondary)

            Button {
              withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                autonomousHumanApproved.toggle()
                emergencyChangeApproved = true
                incidentBridgeOpened = true
              }
            } label: {
              Label(
                autonomousHumanApproved ? "Aprovado" : "Aprovar guardrail",
                systemImage: autonomousHumanApproved
                  ? "checkmark.seal.fill" : "person.badge.shield.checkmark.fill"
              )
            }
            .buttonStyle(.bankPrimary)
          }

          Text("Decisão humana: \(workflow.run.nextHumanDecision)")
            .font(BankTheme.Typography.caption)
            .foregroundColor(.white.opacity(0.72))
            .fixedSize(horizontal: false, vertical: true)

          HStack(spacing: BankTheme.Spacing.sm) {
            ForEach(workflow.citations) { citation in
              CitationPill(citation: citation)
            }
          }
        }
      }
    }
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
        .tint(BankTheme.Palette.brandAction)
        .padding(.horizontal, BankTheme.Spacing.xs)
    }
  }

  private var assistantPanel: some View {
    VisualCard(fill: BankTheme.Palette.graphite) {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.lg) {
        HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
          IconBubble(
            symbolName: "sparkles",
            color: BankTheme.Palette.brandRed,
            size: BankTheme.Size.iconBubble
          )

          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            Text("now.assist.title")
              .font(BankTheme.Typography.section)
              .foregroundColor(.white)

            Text("now.assist.detail")
              .font(BankTheme.Typography.body)
              .foregroundColor(.white.opacity(0.84))
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
    .tint(BankTheme.Palette.brandAction)
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
          color: BankTheme.Palette.brandSecondary,
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

  private var customerExperienceCenter: some View {
    VStack(spacing: BankTheme.Spacing.md) {
      SectionHeader("now.customer.title")

      VisualCard {
        VStack(spacing: BankTheme.Spacing.md) {
          ForEach(Array(customerExperienceItems.enumerated()), id: \.element.id) { index, item in
            CustomerExperienceRow(item: item)

            if index < customerExperienceItems.count - 1 {
              Divider()
            }
          }
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

private struct ExecutivePulseRing: View {
  let value: Double
  let color: Color

  private var percent: Int {
    Int(min(max(value, 0), 1) * 100)
  }

  var body: some View {
    ZStack {
      Circle()
        .stroke(Color.white.opacity(0.12), lineWidth: 9)

      Circle()
        .trim(from: 0, to: min(max(value, 0), 1))
        .stroke(color, style: StrokeStyle(lineWidth: 9, lineCap: .round))
        .rotationEffect(.degrees(-90))

      VStack(spacing: 0) {
        Text("\(percent)")
          .font(BankTheme.Typography.metric)
          .foregroundColor(.white)

        Text("pronto")
          .font(BankTheme.Typography.micro)
          .foregroundColor(.white.opacity(0.66))
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text("Prontidão \(percent)%"))
  }
}

private struct NowDecisionActionRow: View {
  let title: String
  let detail: String
  let symbolName: String
  let color: Color
  let isDone: Bool
  let doneText: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(alignment: .center, spacing: BankTheme.Spacing.md) {
        Image(systemName: isDone ? "checkmark.seal.fill" : symbolName)
          .font(BankTheme.Typography.headline)
          .foregroundColor(isDone ? BankTheme.Palette.success : color)
          .frame(width: 42, height: 42)
          .background(
            Circle()
              .fill((isDone ? BankTheme.Palette.success : color).opacity(0.16))
          )

        VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
          Text(isDone ? doneText : title)
            .font(BankTheme.Typography.headline)
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)

          Text(detail)
            .font(BankTheme.Typography.caption)
            .foregroundColor(.white.opacity(0.68))
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: BankTheme.Spacing.sm)

        Image(systemName: isDone ? "checkmark.circle.fill" : "chevron.right")
          .font(BankTheme.Typography.callout)
          .foregroundColor(isDone ? BankTheme.Palette.success : .white.opacity(0.56))
      }
      .padding(BankTheme.Spacing.sm)
      .background(
        RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
          .fill(Color.white.opacity(isDone ? 0.11 : 0.07))
      )
    }
    .buttonStyle(.plain)
  }
}

private struct WarRoomSignalBoard: View {
  let isItau: Bool
  let changeApproved: Bool
  let bridgeOpened: Bool
  let requestReleased: Bool

  private var items: [(title: String, value: String, color: Color)] {
    [
      ("Change", changeApproved ? "aprovada" : "pendente", BankTheme.Palette.warning),
      ("Incidente", bridgeOpened ? "ponte ativa" : "aguardando", BankTheme.Palette.attention),
      ("Pedido", requestReleased ? "fulfillment" : "fila", BankTheme.Palette.brandRed),
      (
        "Cliente",
        isItau ? "Personnalité" : "Prime",
        isItau ? BankTheme.Palette.brandSecondary : BankTheme.Palette.brandAction
      ),
    ]
  }

  var body: some View {
    VStack(alignment: .leading, spacing: BankTheme.Spacing.md) {
      Text("Sinais da war room")
        .font(BankTheme.Typography.caption)
        .foregroundColor(.white.opacity(0.72))

      HStack(spacing: BankTheme.Spacing.sm) {
        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
          VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
            Circle()
              .fill(item.color)
              .frame(width: 8, height: 8)

            Text(item.title)
              .font(BankTheme.Typography.micro)
              .foregroundColor(.white.opacity(0.62))
              .lineLimit(1)
              .minimumScaleFactor(0.82)

            Text(item.value)
              .font(BankTheme.Typography.caption)
              .foregroundColor(.white)
              .lineLimit(1)
              .minimumScaleFactor(0.74)
          }
          .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
          .padding(BankTheme.Spacing.sm)
          .background(
            RoundedRectangle(cornerRadius: BankTheme.Radius.sm, style: .continuous)
              .fill(Color.white.opacity(0.07))
          )
        }
      }
    }
  }
}

private struct AutonomousStepRow: View {
  let step: AutonomousWorkflowStep
  let isActive: Bool
  let isApproved: Bool

  private var accent: Color {
    if step.requiresHumanApproval && !isApproved { return BankTheme.Palette.warning }
    return isActive || isApproved ? BankTheme.Palette.success : BankTheme.Palette.brandAction
  }

  private var displayedState: String {
    if step.requiresHumanApproval && isApproved { return "aprovado" }
    if isActive && step.state == "pronto" { return "executando" }
    return step.state
  }

  var body: some View {
    HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
      VStack(spacing: BankTheme.Spacing.xs) {
        Circle()
          .fill(accent)
          .frame(width: 11, height: 11)

        Rectangle()
          .fill(Color.white.opacity(0.16))
          .frame(width: 2, height: 42)
      }

      VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
        HStack(alignment: .firstTextBaseline, spacing: BankTheme.Spacing.sm) {
          Text(step.phase.uppercased())
            .font(BankTheme.Typography.caption)
            .foregroundColor(accent)

          Text(displayedState)
            .font(BankTheme.Typography.caption)
            .foregroundColor(.white.opacity(0.68))

          Spacer(minLength: 0)
        }

        Text(step.action)
          .font(BankTheme.Typography.headline)
          .foregroundColor(.white)
          .fixedSize(horizontal: false, vertical: true)

        Text(step.ownerAgent)
          .font(BankTheme.Typography.caption)
          .foregroundColor(.white.opacity(0.72))

        Text(step.evidence)
          .font(BankTheme.Typography.caption)
          .foregroundColor(.white.opacity(0.62))
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(BankTheme.Spacing.sm)
    .background(
      RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
        .fill(Color.white.opacity(0.07))
    )
  }
}

private struct AutonomousAgentChip: View {
  let agent: AutonomousAgent

  var body: some View {
    VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
      Text(agent.domain)
        .font(BankTheme.Typography.micro)
        .foregroundColor(BankTheme.Palette.brandAction)
        .lineLimit(1)
        .minimumScaleFactor(0.84)

      Text(agent.name)
        .font(BankTheme.Typography.caption)
        .foregroundColor(.white)
        .lineLimit(2)
        .minimumScaleFactor(0.8)
    }
    .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
    .padding(BankTheme.Spacing.sm)
    .background(
      RoundedRectangle(cornerRadius: BankTheme.Radius.sm, style: .continuous)
        .fill(Color.white.opacity(0.08))
    )
    .accessibilityHint(Text(agent.currentWork))
  }
}

private struct GovernancePill: View {
  let title: String
  let isOn: Bool

  var body: some View {
    Label(title, systemImage: isOn ? "checkmark.shield.fill" : "xmark.shield.fill")
      .font(BankTheme.Typography.caption)
      .foregroundColor(isOn ? BankTheme.Palette.success : BankTheme.Palette.warning)
      .lineLimit(1)
      .minimumScaleFactor(0.84)
      .frame(maxWidth: .infinity)
      .padding(.vertical, BankTheme.Spacing.sm)
      .background(
        Capsule(style: .continuous)
          .fill(Color.white.opacity(0.08))
      )
  }
}

private struct CitationPill: View {
  let citation: AutonomousCitation

  var body: some View {
    VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
      Text(citation.label)
        .font(BankTheme.Typography.caption)
        .foregroundColor(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.86)

      Text(citation.source)
        .font(BankTheme.Typography.micro)
        .foregroundColor(.white.opacity(0.64))
        .lineLimit(2)
        .minimumScaleFactor(0.82)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(BankTheme.Spacing.sm)
    .background(
      RoundedRectangle(cornerRadius: BankTheme.Radius.sm, style: .continuous)
        .fill(Color.white.opacity(0.07))
    )
  }
}

private struct JourneyTwinCard: View {
  let twin: NowJourneyTwin
  @Binding var activeIndex: Int
  let action: () -> Void

  private var activeNode: NowJourneyNode {
    twin.nodes[min(activeIndex, twin.nodes.count - 1)]
  }

  private var compactAuditId: String {
    twin.auditId.replacingOccurrences(of: "2026-", with: "")
  }

  var body: some View {
    VisualCard(fill: BankTheme.Palette.graphite) {
      VStack(alignment: .leading, spacing: BankTheme.Spacing.lg) {
        HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
          VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
            Text("now.twin.eyebrow")
              .font(BankTheme.Typography.caption)
              .foregroundColor(BankTheme.Palette.brandRed)

            Text(twin.title)
              .font(BankTheme.Typography.section)
              .foregroundColor(.white)
              .fixedSize(horizontal: false, vertical: true)
          }

          Spacer(minLength: BankTheme.Spacing.sm)

          Label {
            Text(compactAuditId)
              .lineLimit(1)
              .minimumScaleFactor(0.86)
          } icon: {
            Image(systemName: "waveform.path.ecg")
          }
          .font(BankTheme.Typography.caption)
          .foregroundColor(BankTheme.Palette.brandRed)
          .padding(.horizontal, BankTheme.Spacing.sm)
          .padding(.vertical, BankTheme.Spacing.xs)
          .background(
            Capsule(style: .continuous)
              .fill(BankTheme.Palette.brandRed.opacity(0.16))
          )
        }

        Text(twin.hypothesis)
          .font(BankTheme.Typography.body)
          .foregroundColor(.white.opacity(0.84))
          .fixedSize(horizontal: false, vertical: true)

        JourneyRail(nodes: twin.nodes, activeIndex: activeIndex)
          .frame(height: 122)

        HStack(spacing: BankTheme.Spacing.md) {
          JourneyMetric(
            value: twin.minutesSaved,
            titleKey: "now.twin.metric.time",
            symbolName: "bolt.fill",
            color: BankTheme.Palette.brandRed
          )

          JourneyMetric(
            value: twin.riskDelta,
            titleKey: "now.twin.metric.risk",
            symbolName: "arrow.down.forward.circle.fill",
            color: BankTheme.Palette.success
          )
        }

        ActiveNodePanel(node: activeNode)

        HStack(spacing: BankTheme.Spacing.sm) {
          Button {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
              activeIndex = activeIndex >= twin.nodes.count - 1 ? 0 : activeIndex + 1
            }
          } label: {
            Label("now.twin.advance", systemImage: "forward.frame.fill")
          }
          .buttonStyle(.bankSecondary)

          Button(action: action) {
            Label("now.twin.action", systemImage: "sparkles")
          }
          .buttonStyle(.bankPrimary)
        }

        HStack(spacing: BankTheme.Spacing.sm) {
          ForEach(twin.pulses) { pulse in
            JourneyPulsePill(pulse: pulse)
          }
        }
      }
    }
  }
}

private struct JourneyRail: View {
  let nodes: [NowJourneyNode]
  let activeIndex: Int

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(alignment: .top, spacing: BankTheme.Spacing.sm) {
        ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
          let isActive = index == activeIndex
          let isComplete = index <= activeIndex

          JourneyNodeDot(node: node, isActive: isActive, isComplete: isComplete)
            .frame(width: 82)
        }
      }
      .padding(.horizontal, BankTheme.Spacing.xs)
      .padding(.vertical, BankTheme.Spacing.xs)
    }
  }
}

private struct JourneyNodeDot: View {
  let node: NowJourneyNode
  let isActive: Bool
  let isComplete: Bool

  private var color: Color {
    if node.isCritical { return BankTheme.Palette.warning }
    return isComplete ? BankTheme.Palette.brandRed : Color.white.opacity(0.42)
  }

  var body: some View {
    VStack(spacing: BankTheme.Spacing.xs) {
      ZStack {
        Circle()
          .fill(isComplete ? color.opacity(0.22) : Color.white.opacity(0.10))
          .frame(width: isActive ? 52 : 42, height: isActive ? 52 : 42)

        Circle()
          .stroke(color, lineWidth: isActive ? 3 : 1)
          .frame(width: isActive ? 42 : 32, height: isActive ? 42 : 32)

        Image(systemName: node.symbolName)
          .font(.system(size: isActive ? 18 : 14, weight: .semibold, design: .default))
          .foregroundColor(isComplete ? color : .white.opacity(0.58))
      }

      Text(node.title)
        .font(BankTheme.Typography.micro)
        .foregroundColor(isActive ? .white : .white.opacity(0.7))
        .lineLimit(2)
        .multilineTextAlignment(.center)
        .minimumScaleFactor(0.9)
        .frame(width: 82)
    }
  }
}

private struct JourneyMetric: View {
  let value: String
  let titleKey: LocalizedStringKey
  let symbolName: String
  let color: Color

  var body: some View {
    HStack(spacing: BankTheme.Spacing.sm) {
      Image(systemName: symbolName)
        .foregroundColor(color)
        .frame(width: BankTheme.Size.compactIconBubble, height: BankTheme.Size.compactIconBubble)
        .background(Circle().fill(color.opacity(0.16)))

      VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
        Text(value)
          .font(BankTheme.Typography.metric)
          .foregroundColor(.white)
          .lineLimit(1)
          .minimumScaleFactor(0.86)

        Text(titleKey)
          .font(BankTheme.Typography.caption)
          .foregroundColor(.white.opacity(0.76))
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(BankTheme.Spacing.md)
    .background(
      RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
        .fill(Color.white.opacity(0.08))
    )
  }
}

private struct ActiveNodePanel: View {
  let node: NowJourneyNode

  private var confidenceText: String {
    "\(Int(node.confidence * 100))%"
  }

  var body: some View {
    HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
      IconBubble(
        symbolName: node.symbolName,
        color: node.isCritical ? BankTheme.Palette.warning : BankTheme.Palette.brandRed,
        size: BankTheme.Size.compactIconBubble
      )

      VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
        HStack(alignment: .firstTextBaseline) {
          Text(node.title)
            .font(BankTheme.Typography.headline)
            .foregroundColor(.white)

          Spacer(minLength: BankTheme.Spacing.sm)

          Text(confidenceText)
            .font(BankTheme.Typography.caption)
            .foregroundColor(BankTheme.Palette.brandRed)
        }

        Text(node.subtitle)
          .font(BankTheme.Typography.body)
          .foregroundColor(.white.opacity(0.84))
          .fixedSize(horizontal: false, vertical: true)

        Text(node.owner)
          .font(BankTheme.Typography.caption)
          .foregroundColor(.white.opacity(0.7))
      }
    }
    .padding(BankTheme.Spacing.md)
    .background(
      RoundedRectangle(cornerRadius: BankTheme.Radius.md, style: .continuous)
        .fill(Color.white.opacity(0.08))
    )
  }
}

private struct JourneyPulsePill: View {
  let pulse: NowJourneyPulse

  var body: some View {
    VStack(alignment: .leading, spacing: BankTheme.Spacing.xxs) {
      Label {
        Text(pulse.metric)
          .lineLimit(1)
          .minimumScaleFactor(0.9)
      } icon: {
        Image(systemName: pulse.symbolName)
      }
      .font(BankTheme.Typography.caption)
      .foregroundColor(.white)

      Text(pulse.title)
        .font(BankTheme.Typography.micro)
        .foregroundColor(.white.opacity(0.78))
        .lineLimit(1)
        .minimumScaleFactor(0.9)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(BankTheme.Spacing.sm)
    .background(
      RoundedRectangle(cornerRadius: BankTheme.Radius.sm, style: .continuous)
        .fill(Color.white.opacity(0.07))
    )
    .accessibilityElement(children: .combine)
    .accessibilityHint(Text(pulse.detail))
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
          .font(BankTheme.Typography.callout)
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

private struct CustomerExperienceRow: View {
  let item: CustomerExperienceItem

  private var color: Color {
    switch item.domain {
    case .csm: return BankTheme.Palette.attention
    case .crm: return BankTheme.Palette.brandRed
    }
  }

  private var domainLabel: String {
    item.domain.rawValue.uppercased()
  }

  var body: some View {
    HStack(alignment: .top, spacing: BankTheme.Spacing.md) {
      IconBubble(
        symbolName: item.symbolName,
        color: color,
        size: BankTheme.Size.compactIconBubble
      )

      VStack(alignment: .leading, spacing: BankTheme.Spacing.xs) {
        HStack(alignment: .firstTextBaseline, spacing: BankTheme.Spacing.sm) {
          Text(item.title)
            .font(BankTheme.Typography.headline)
            .foregroundColor(BankTheme.Palette.ink)
            .fixedSize(horizontal: false, vertical: true)

          Spacer(minLength: BankTheme.Spacing.sm)

          StatusBadge(title: domainLabel, color: color, symbolName: "circle.fill")
        }

        Text(item.detail)
          .font(BankTheme.Typography.body)
          .foregroundColor(BankTheme.Palette.secondaryInk)
          .fixedSize(horizontal: false, vertical: true)

        HStack(spacing: BankTheme.Spacing.md) {
          Label(item.metric, systemImage: "speedometer")
          Label(item.owner, systemImage: "person.2.fill")
        }
        .font(BankTheme.Typography.caption)
        .foregroundColor(BankTheme.Palette.mutedInk)
      }
    }
    .accessibilityElement(children: .combine)
  }
}

private struct WorkItemCard: View {
  let item: NowWorkItem

  private var accentColor: Color {
    switch item.domain {
    case .itsm:
      if item.priority == "P0" || item.priority == "P1" { return BankTheme.Palette.warning }
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
            .foregroundColor(BankTheme.Palette.brandSecondary)

          Text(item.signal)
            .font(BankTheme.Typography.caption)
            .foregroundColor(BankTheme.Palette.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BankTheme.Spacing.sm)
        .background(
          RoundedRectangle(cornerRadius: BankTheme.Radius.sm, style: .continuous)
            .fill(BankTheme.Palette.subtleSurface)
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
        .minimumScaleFactor(0.86)
    } icon: {
      Image(systemName: symbolName)
    }
    .font(BankTheme.Typography.caption)
    .foregroundColor(BankTheme.Palette.secondaryInk)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
