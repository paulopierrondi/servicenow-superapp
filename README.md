# ServiceNow Super App Mobile — Bradesco + Itaú tenants

> Repositório do super app móvel multi-tenant. O foco do produto é ServiceNow: command center, catálogo, workspaces, ITSM, SPM, CSM, CRM, trust e Now Assist. Bradesco e Itaú entram como skins/contextos corporativos, não como apps transacionais bancários.

---

## Quick start

```bash
# Pré-requisitos: Mac com Xcode 15.4+, Homebrew, Node 20+
make install-tools     # instala XcodeGen, SwiftLint, mmdc

# Gerar Xcode project a partir de project.yml
make xcode

# Abrir no Xcode
open ios/BankApp.xcodeproj

# Rodar tudo (lint + build + test + contract)
make verify
```

## Para agentes (Claude Code, Codex)

**Antes de qualquer ação, leia:**

1. [`AGENTS.md`](./AGENTS.md) — constitution vinculante.
2. [`docs/integration-with-now-mobile.md`](./docs/integration-with-now-mobile.md) — como o app vive no ecossistema oficial ServiceNow.
3. [`docs/adr/`](./docs/adr/) — decisões arquiteturais.
4. [`prompts/`](./prompts/) — kickoff prompts por fase.

## Arquitetura em 1 minuto

```
Usuário → Apps Nativos SwiftUI Bradesco/Itaú + NowSDK ──┐
              ↕ Universal Links         │
         Branded App (Mobile Publishing)│
                                        ↓
                          ServiceNow x_bank scoped app
                          (Scripted REST v1, Flow, ACLs,
                           consent, NowAssist, audit)
                                        ↓
                          Railway aux: mock harness,
                          BFF flags, OTel collector,
                          agent orchestrator
                                        ↓
                          Core bancário via API Gateway
```

## Estrutura

| Diretório | Conteúdo |
|---|---|
| `ios/` | App SwiftUI nativo, XcodeGen, targets Bradesco/Itaú e configs por ambiente |
| `servicenow/` | Scoped app `x_bank`, Scripted REST versionado, ATF tests, update sets |
| `railway/services/` | Mock harness, BFF flags, OTel collector, agent orchestrator |
| `docs/adr/` | Architecture Decision Records (PT-BR) |
| `docs/runbooks/` | Incident, rollback, refresh metadata (PT-BR) |
| `docs/diagrams/` | Diagramas Mermaid |
| `docs/compliance/` | LGPD, CMN 4.893/2021, Open Finance |
| `prompts/` | Kickoff prompts para Claude Code e Codex |
| `.github/workflows/` | CI iOS, CI Railway, release phased |
| `fastlane/` | Code signing via match (CI) |

## Ambientes

| Env | iOS scheme | Bundle ID | ServiceNow | Railway |
|---|---|---|---|---|
| Bradesco Dev | `BankApp-Bradesco-Dev` / `BankApp-Dev` | `com.bradesco.mobile.app.dev` | dev-bradesco.service-now.com | `servicenow-superapp` |
| Itaú Dev | `BankApp-Itau-Dev` | `com.itau.mobile.app.dev` | dev-itau.service-now.com | `servicenow-superapp` |
| Staging | `BankApp-Staging` | `com.bradesco.mobile.app.staging` | staging-bradesco.service-now.com | `*-staging.up.railway.app` |
| Prod | `BankApp-Prod` | `com.bradesco.mobile.app` | bradesco.service-now.com | `*.up.railway.app` |
| Demo | `BankApp-Demo` | `com.bradesco.mobile.app.demo` | demo-bradesco.service-now.com | `*-demo.up.railway.app` |

## Evolução Now Mobile

A entrada do app deixa o usuário escolher Bradesco ou Itaú e aplica tema, segmento e relacionamento em runtime. Depois disso, a primeira tela é um `NowOS Command Center`: ServiceNow é a experiência principal, com grafo operacional, catálogo por intenção, aprovações, fila offline, respostas com citação, ITSM, SPM, CSM, CRM, trust, Otto / Now Assist e workflows agentic no mesmo fluxo.

## Feature Assinatura

O `Gêmeo Operacional da Jornada` transforma uma intenção bancária em um mapa vivo antes da execução: cliente, consentimento, risco, Otto / Now Assist, ITSM, SPM e auditoria aparecem conectados em uma trilha interativa. A ideia é mostrar o impacto operacional de um Pix contestado, aprovação ou mudança antes de abrir chamados manuais.

O `Autonomous Workforce Run` leva isso para execução governada: AIOps AI Specialist detecta e correlaciona sinais, L1 Service Desk AI Specialist faz triagem, CRM Case Management AI Specialist prepara case/comunicação, e AI Control Tower segura a ação sensível até aprovação humana, com least privilege, prompt-shield, citações KB/CMDB/CAB e trilha de auditoria.

A aba `Work` agora também mostra a camada de plataforma: Otto interpreta intenção, Action Fabric/MCP Server expõe tools ServiceNow com política, Workflow Data Fabric/Context Engine cruza contexto sem copiar dados, e AI Control Tower mede risco, policy pass e autonomia liberada.

## Cores e UI

O app usa uma base visual nativa iOS, com fundo grouped `#F2F2F7`, superfícies brancas e sem preenchimentos pesados de marca. As cores oficiais entram como acento: Bradesco `#CC092F` e `#900F15`; Itaú `#EC7000` e `#003399`.

## ServiceNow e Railway

Os endpoints `mobile-work` e `mobile-agentic-workflow` expõem os contratos v1 para ITSM, SPM, CSM, CRM, launcher, action items, respostas sintetizadas, `journeyTwin`, AI specialists, guardrails e execução agentic governada, usados pela aba `Now` e pelo mordomo Otto / Now Assist. O projeto Railway criado é `servicenow-superapp`; os ids dos services estão em `railway/project-manifest.json`.

Para expor o demo em uma instância sem gravar credenciais no repo:

```bash
SN_INSTANCE_URL=https://sua-instancia.service-now.com \
SN_USERNAME=admin \
SN_PASSWORD='...' \
node servicenow/deploy/deploy-agentic-rest.mjs

SN_INSTANCE_URL=https://sua-instancia.service-now.com \
SN_USERNAME=admin \
SN_PASSWORD='...' \
node servicenow/seed/seed-agentic-workflow.mjs
```

## Compliance

Toda mudança que toque dado pessoal/financeiro/nuvem precisa de ADR com cabeçalho:

```
LGPD: <impacto / base legal>
CMN 4.893/2021: <controle aplicável / país de processamento>
Open Finance Brasil: <FAPI 1.0 perfil aplicável? sim/não>
```

## Owner

Paulo Henrique Carneiro Pierrondi — TAE ServiceNow / Bradesco
