# ADR-015 — Railway como hospedagem de serviços auxiliares

**Status:** Proposto  
**Data:** 2026-05-10  
**Owner:** Paulo Henrique Carneiro Pierrondi  
**LGPD:** alguns serviços (BFF flags, OTel collector) processam dados pessoais — base legal: legítimo interesse + consentimento opt-in para telemetria  
**CMN 4.893/2021:** alta atenção — Railway é provedor de nuvem; documentar país de processamento, país de armazenamento, plano de continuidade  
**Open Finance Brasil:** não aplicável diretamente

## Contexto

Há funções auxiliares que **não cabem ou não rodam bem dentro da instância ServiceNow**:

1. **Mock harness** para contract tests CI sem dependência de instância live.
2. **BFF de feature flags** com latência <100ms para clientes em rede instável (instância pode estar a 800ms+).
3. **OpenTelemetry collector** para forwarding de telemetria do app iOS para o destino observabilidade.
4. **Agent orchestrator** (webhook intermediário Linear ↔ GitHub ↔ Claude Code/Codex) para automação de PRs e tickets.

Hospedar tudo na instância sobrecarrega scripted REST e mistura responsabilidade de negócio com infraestrutura. Hospedar em AWS/GCP exige time de SRE dedicado. Railway resolve em meio termo: PaaS gerenciado, Docker-first, deploy por git push, observabilidade nativa, baixo custo operacional.

## Decisão

Adotar Railway como camada de hospedagem para os 4 serviços auxiliares acima.

Cada serviço:
- Roda em container Docker próprio (multi-stage, user não-root, healthcheck).
- Tem `railway.json` próprio em `railway/services/<nome>/`.
- Tem ambientes `dev`, `staging`, `prod` separados.
- Health check `/health` obrigatório.
- Logs estruturados JSON.
- Secrets via Railway env vars (nunca em xcconfig ou no repo).

## Não-decisões (limites)

❌ Railway **não** hospeda dado bancário em repouso. Banco de dados de cliente fica na instância ServiceNow ou no core bancário, nunca em Postgres do Railway sem ADR específico.  
❌ Railway **não** processa pagamento, consentimento ou autorização. Esses fluxos vivem na instância.  
❌ Railway **não** substitui auditoria CMN — qualquer serviço Railway que toque dado regulado precisa contrato, due diligence e plano de saída documentados antes de ir para prod.

## Mapa dos serviços

| Serviço | Imagem | Função | Toca dado pessoal? | Pode ir para prod? |
|---|---|---|---|---|
| mock-harness | Node 20 | Contract tests CI | Não (mocks) | Não — só dev/staging |
| bff-feature-flags | Node 20 (Fastify) | Edge fallback de flags com cache | Pseudonimizado (client version) | Sim, com ADR + due diligence CMN |
| otel-collector | OpenTelemetry collector contrib | Forwarding de tracing/metrics/logs | Sim — métricas com user_id pseudonimizado | Sim, com ADR + DPIA |
| agent-orchestrator | Node 20 + scripts | Webhook Linear↔Github↔Claude Code | Não (apenas metadata de tickets) | Sim |

## Region

Decisão pendente (DEC-205): qual region Railway escolher para compatibilidade CMN 4.893/2021. Opções:

- `us-east` (default Railway) — alta latência para Brasil.
- `us-west` — pior latência ainda.
- Self-hosted em região br via fly.io ou AWS São Paulo — fora do escopo do Railway.

Mitigação inicial: usar Railway só para componentes não-críticos em latência absoluta (mock + BFF com cache + OTel buffer). Componentes ultra-críticos (consent, auth) ficam na instância (que tem datacenter Brasil).

## Estrutura

```
railway/
├── railway.json               (raiz, placeholder)
└── services/
    ├── mock-harness/
    │   ├── Dockerfile
    │   ├── package.json
    │   ├── server.js
    │   └── railway.json
    ├── bff-feature-flags/
    │   ├── Dockerfile
    │   ├── package.json
    │   ├── tsconfig.json
    │   ├── index.ts
    │   └── railway.json
    ├── otel-collector/
    │   ├── Dockerfile
    │   ├── otel-config.yaml
    │   └── railway.json
    └── agent-orchestrator/
        ├── Dockerfile
        ├── package.json
        ├── webhook-handlers/
        └── railway.json
```

## Decision gates

- DEC-205: region Railway final (compatibilidade CMN).
- DEC-215: política de continuidade — qual provedor é fallback se Railway sair.
- DEC-216: due diligence CMN para Railway (subprocessor list, country of processing).

## Referências

- AGENTS.md §3, §9.
- docs/integration-with-now-mobile.md §6.
