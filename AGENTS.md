# AGENTS.md — Bradesco Mobile (ServiceNow-powered) — v2.0

> Constitution para agentes de codificação (Claude Code, Codex, qualquer outro). Lida em toda sessão. Atualizada via PR com revisão humana.

---

## 1. Tese do produto

App móvel bancário **ServiceNow-powered**, distribuído com binário próprio do banco, integrado em 5 pontos ao ecossistema oficial ServiceNow Mobile:

1. **Shell iOS nativo SwiftUI** com **NowSDK embarcado** (telemetria, NowAssist chat, theming, services).
2. **Backend único** na instância ServiceNow via **Scoped App `x_bank`** (Scripted REST versionado, Flow, ACLs, consent model).
3. **Companion app branded** via **Mobile Publishing** ServiceNow para jornadas operacionais e atendimento delegado.
4. **Deep linking bidirecional** entre nativo e branded (Universal Links + custom schemes).
5. **IdP + NowAssist compartilhados** entre os apps do mesmo cliente.

O agente entrega scaffold + reference impl + testes + documentação. **Não entrega código aprovado para App Review, auditoria CMN 4.893/2021 ou pen-test bancário.** Toda decisão que toque cliente final exige revisão humana explícita.

---

## 2. Decisões arquiteturais (ADRs vinculantes)

| ADR | Decisão |
|---|---|
| 001 | Shell iOS nativo SwiftUI + Mobile SDK ServiceNow |
| 002 | OIDC/OAuth2 com browser externo gerido (`ASWebAuthenticationSession`) |
| 003 | Biometria local (`LocalAuthentication`) só como step-up |
| 004 | Scripted REST versionado em path `/api/x_bank/v{N}/...`, convivência v1/v2 |
| 005 | Feature flags server-side no payload + fallback BFF Railway |
| 006 | Schema handshake via headers `X-Client-Version` + `X-Client-Schema-Version` |
| 007 | ATS + `NSPinnedDomains` apenas no app nativo |
| 008 | Mobile impersonation BANIDO como atendimento; usar delegated access |
| 009 | Cohorts separados para offline e ZTA |
| 010 | iOS 15+ baseline (alinha com Bradesco App Store) |
| 011 | NowSDK adotado via SPM/XCFramework no app nativo |
| 012 | Companion branded app via Mobile Publishing (Fase 4) |
| 013 | Deep linking universal `https://m.bradesco.com.br/*` + scheme `bradesco-app://` |
| 014 | XcodeGen como gerador de `.xcodeproj` a partir de `project.yml` |
| 015 | Railway hospeda 4 serviços auxiliares: mock harness, BFF flags, OTel collector, agent orchestrator |
| 016 | fastlane `match` para code signing em CI; nada de auto-signing |
| 017 | OpenTelemetry → ServiceNow Cloud Observability como pipe único |
| 018 | Linear como sistema de backlog canônico; agente fecha tickets via MCP |

ADRs detalhados em `docs/adr/NNNN-titulo.md`, todos em PT-BR.

---

## 3. Repo layout

```
.
├── AGENTS.md                       (este arquivo, lido por agentes)
├── CLAUDE.md                       (symlink → AGENTS.md)
├── README.md                       (visão humana do repo)
├── Makefile                        (verify, lint, test, deploy)
├── ios/
│   ├── project.yml                 (XcodeGen — fonte da verdade do .xcodeproj)
│   ├── BankApp.xcodeproj           (gerado, .gitignore o conteúdo binário)
│   ├── Configs/
│   │   ├── Base.xcconfig           (settings comuns)
│   │   ├── Debug.xcconfig
│   │   ├── Release.xcconfig
│   │   ├── Dev.xcconfig            (instância dev, mock harness Railway)
│   │   ├── Staging.xcconfig        (sandbox SN, IdP staging)
│   │   ├── Prod.xcconfig           (instância prod, IdP prod)
│   │   └── Demo.xcconfig           (env para demos comerciais)
│   ├── BankApp/
│   │   ├── Info.plist
│   │   ├── PrivacyInfo.xcprivacy
│   │   ├── BankApp.entitlements
│   │   ├── App/                    (entry, scenes, root)
│   │   ├── Auth/                   (OIDC, BiometricGate, TokenStore)
│   │   ├── Network/                (ServiceNowClient, DTOs)
│   │   ├── DesignSystem/           (tokens, components SwiftUI)
│   │   ├── Features/{Home,Payments,Security,Support,Profile}/
│   │   ├── Observability/          (OTel, debug drawer parity)
│   │   ├── FeatureFlags/           (server-side + BFF fallback)
│   │   ├── DeepLink/               (universal links + schemes)
│   │   └── NowSDKBridge/           (wrapper sobre NowSDK)
│   ├── BankAppTests/
│   ├── BankAppUITests/
│   └── Packages/                   (SPM locais)
├── servicenow/
│   ├── scoped-app/                 (x_bank: ACLs, BR, scripts, tabelas)
│   │   ├── sys_scope.xml
│   │   └── tables/
│   ├── scripted-rest/
│   │   ├── v1/
│   │   │   ├── mobile-home.js
│   │   │   ├── mobile-payments.js
│   │   │   ├── mobile-feature-flags.js
│   │   │   └── mobile-consent.js
│   │   └── v2/                     (futuro)
│   ├── flows/                      (Flow Designer specs)
│   ├── tests/
│   │   ├── atf/                    (ATF suites)
│   │   └── mock-harness-spec/      (contract tests)
│   ├── consent-model/              (delegated access schema)
│   └── update-set/                 (XMLs versionados por release)
├── railway/
│   ├── railway.json                (project config)
│   ├── services/
│   │   ├── mock-harness/           (Node — replicador de Scripted REST p/ tests)
│   │   ├── bff-feature-flags/      (TS — flags edge low-latency)
│   │   ├── otel-collector/         (config OTel collector)
│   │   └── agent-orchestrator/     (Claude Code + Codex automation)
│   └── docs/                       (deploy notes por serviço)
├── docs/
│   ├── adr/                        (PT-BR)
│   ├── runbooks/                   (incident, rollback, refresh metadata)
│   ├── compliance/                 (LGPD, CMN 4.893, Open Finance)
│   ├── diagrams/                   (Mermaid)
│   ├── integration-with-now-mobile.md (PEÇA CENTRAL: como o app vive no ecossistema oficial)
│   └── session-log/                (logs de sessão de agente)
├── prompts/                        (kickoff e fase prompts)
├── .github/workflows/              (CI iOS, CI Railway, release phased)
├── fastlane/                       (Fastfile, Matchfile)
└── .codex/                         (setup.sh para Codex sandbox)
```

---

## 4. Comandos canônicos

```bash
# Geração de Xcode project a partir de project.yml
make xcode

# Build iOS (Debug, simulator)
make ios-build

# Test iOS (unit + snapshot + integration)
make ios-test

# Lint Swift
make ios-lint

# Mock harness Railway local
make mock-harness-run

# Validar contrato Scripted REST contra mock harness
make contract-test

# Validar diagramas Mermaid
make diagrams

# Tudo (gate de DoD)
make verify

# Deploy Railway (apenas humano, via tag)
make deploy-railway-staging
```

Se um comando não existir, **crie** (não pule). Atualize `Makefile` no mesmo PR.

---

## 5. Convenções de código

### Swift / iOS
- Swift 5.9+, SwiftUI, `async/await`. UIKit só via `UIViewControllerRepresentable`.
- Cor/spacing/font hardcoded em view = falha. Use `BankTheme` (`DesignSystem/Tokens.swift`).
- DTO com `schemaVersion: String` obrigatório.
- Token sempre em `Keychain` com `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`. **Nunca** `UserDefaults`.
- Mensagens ao usuário em PT-BR via `Localizable.strings`. Copy bancária final: marcar `// REVISÃO PT-BR HUMANA OBRIGATÓRIA`.
- Acessibilidade: `accessibilityLabel` + `accessibilityHint` em CTAs e itens de lista.
- Dependências externas (SPM ou XCFramework) exigem ADR + revisão de privacy manifest.

### NowSDK
- Acesso ao NowSDK só via wrapper em `NowSDKBridge/`. Nunca direto em view ou viewmodel.
- Configuração de instância vem de `Configs/{Env}.xcconfig`, jamais hardcoded.
- Telemetria do NowSDK respeita opt-out do usuário (consent table na instância).

### JavaScript / Scripted REST
- Pattern `(function process(request, response) { ... })(request, response);`
- Sempre ler headers `X-Client-Version`, `X-Client-Schema-Version`, `X-Client-Platform`.
- Sempre retornar `schemaVersion`, `featureFlags`, `compatibility.minClientVersion`.
- Logs com prefixo `[mobile-v{N}]`.

### TypeScript / Railway services
- Node 20+, TypeScript estrito, ESM.
- Endpoints REST em Fastify ou Hono.
- Logs estruturados JSON (Pino).
- Health check `/health` obrigatório.
- Dockerfile multi-stage com user não-root.

### Mermaid / docs
- Diagramas em `docs/diagrams/*.mmd`.
- ADRs seguem `docs/adr/0000-template.md`. PT-BR.
- Runbooks PT-BR: contexto / gatilho / passos / rollback / owner.

---

## 6. Definition of Done

1. ✅ `make verify` verde.
2. ✅ Lint zero warning.
3. ✅ Diff ≤ 400 linhas; senão dividir.
4. ✅ Conventional Commits.
5. ✅ ADR criado/atualizado se mexer em arquitetura ou contrato.
6. ✅ Mudança de API: bump de `schemaVersion` + ATF test + mock harness atualizado.
7. ✅ Componente SwiftUI: snapshot test + uso de tokens.
8. ✅ Issue Linear fechada, PR linkado.
9. ✅ Copy bancária com flag de revisão humana.

---

## 7. Decision gates (pare e abra issue de decisão)

- IdP de produção, política de sessão, política de step-up.
- Consentimento, delegated access, auditoria.
- Pinned domains, ATS exception.
- Cohort de offline e/ou ZTA.
- Mudança em contrato `v1` em produção.
- Copy bancária de fraude / consentimento / erro.
- Retenção, residência de dados, jurisdição.
- LGPD, CMN 4.893/2021, Open Finance Brasil.
- Adoção formal do NowSDK em produção.
- Aprovação de release em phased rollout.

---

## 8. Anti-padrões (rejeição automática)

- ❌ Mobile impersonation como atendimento ao cliente.
- ❌ Cor/spacing/font hardcoded em view.
- ❌ Endpoint sem versão.
- ❌ DTO sem `schemaVersion`.
- ❌ Pinning ou ATS exception sem ADR.
- ❌ Offline + ZTA na mesma cohort.
- ❌ SAML quando OIDC é viável.
- ❌ Token em `UserDefaults`.
- ❌ Dependência sem ADR + privacy manifest.
- ❌ Copy bancária final sem flag de revisão humana.
- ❌ Concluir sem `make verify`.
- ❌ Acessar NowSDK direto fora de `NowSDKBridge/`.
- ❌ Editar `.xcodeproj` à mão. Edite `project.yml` e regere.
- ❌ Auto-signing. Use `fastlane match`.
- ❌ Secret em xcconfig versionado. Use Railway env / GitHub secrets.

---

## 9. Compliance Brasil

Cabeçalho obrigatório em ADR que toque dado pessoal/financeiro/nuvem:

```
LGPD: <impacto / base legal>
CMN 4.893/2021: <controle aplicável / país de processamento>
Open Finance Brasil: <FAPI 1.0 perfil aplicável? sim/não>
```

Para nuvem (Railway, ServiceNow, OTel destino): documentar país de processamento, país de armazenamento, plano de continuidade em troca de provedor, evidência contratual exigida pela CMN 4.893.

---

## 10. Observabilidade mínima

Toda feature emite:
- `auth.success`, `auth.failure`, `auth.step_up.{success,failure}`
- `api.call` com `endpoint`, `version`, `latency_ms`, `status`, `client_version`
- `feature_flag.evaluated` com `flag_key`, `value`, `source` (server | bff | local)
- `deep_link.received` com `source_app`, `target_route`, `signed_payload_valid`
- `now_sdk.event` quando relevante (chat aberto, telemetria custom)
- `crash` capturado e enviado ao OTel collector

Snapshot/replay de PII: **proibido sem ADR**.

---

## 11. Testes

| Camada | Ferramenta |
|---|---|
| Unit Swift | XCTest |
| Snapshot SwiftUI | swift-snapshot-testing |
| Integration iOS | XCTest + mock harness Railway |
| ATF inbound REST | ServiceNow ATF |
| Smoke flows | ATF (Flow Designer) |
| Contract test | mock harness ↔ Scripted REST real |
| E2E iOS | XCUITest (gate manual antes do piloto) |
| Load test BFF | k6 contra Railway staging |

---

## 12. Loop de execução autônoma

1. Ler `AGENTS.md` + prompt da fase.
2. Listar 5 próximas issues Linear (label `phase-N`, status `Todo`).
3. Para cada issue: mover `In Progress` → executar → `make verify` → commit/PR → Linear `In Review`.
4. Vermelho: 1 retry; senão `BLOCKED` + comentário, próxima.
5. A cada 1h: atualizar `docs/session-log/SESSION-{date}.md`.
6. Final: gerar summary + recomendação para próxima sessão.

Encerrar quando:
- Backlog da fase esgotado.
- 3 issues consecutivas em `BLOCKED`.
- `main` quebrado >30min sem solução.
- 8h cumpridas.

---

## 13. Idioma

- Código, comentários, commits, ADR título: inglês técnico.
- ADR conteúdo, runbook, copy ao usuário, issue Linear, mensagem de erro: PT-BR.
- Diagramas Mermaid: labels PT-BR, nodes técnicos em inglês padrão.

---

**Owner humano:** Paulo Henrique Carneiro Pierrondi (TAE ServiceNow / Bradesco)  
**Última atualização v2.0:** 2026-05-10
