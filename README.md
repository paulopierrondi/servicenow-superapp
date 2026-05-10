# Super App Mobile Bradesco + Itaú — ServiceNow-powered banking app

> Repositório do super app móvel multi-marca. Shell iOS nativo SwiftUI com variantes Bradesco e Itaú, ServiceNow como backend de workflow ITSM/SPM, Now Assist embarcado, Railway para serviços auxiliares e companion branded via Mobile Publishing.

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
Cliente → Apps Nativos SwiftUI Bradesco/Itaú + NowSDK ──┐
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

A aba `Now` segue a lógica operacional do Now Mobile, mas adaptada para banco e multi-marca: busca universal com voz, catálogo por departamento, aprovações, fila offline, respostas com citação, ITSM, SPM e Now Assist no mesmo fluxo.

## ServiceNow e Railway

O endpoint `mobile-work` expõe o contrato v1 para ITSM, SPM, launcher, action items e respostas sintetizadas, usado pela aba `Now`. O projeto Railway criado é `servicenow-superapp`; os ids dos services estão em `railway/project-manifest.json`.

## Compliance

Toda mudança que toque dado pessoal/financeiro/nuvem precisa de ADR com cabeçalho:

```
LGPD: <impacto / base legal>
CMN 4.893/2021: <controle aplicável / país de processamento>
Open Finance Brasil: <FAPI 1.0 perfil aplicável? sim/não>
```

## Owner

Paulo Henrique Carneiro Pierrondi — TAE ServiceNow / Bradesco
