# ADR 0016 — Agentic workflow governado no super app

## Status

Aceita.

## Contexto

O app precisa demonstrar uma experiência atual de Otto / Now Assist, AI specialists,
Autonomous Workforce e AI Control Tower sem depender, no demo local, de plugins ou
licenças específicas ativadas na instância.

## Decisão

Adicionar o contrato `/api/x_bank/v1/mobile-agentic-workflow` para expor:

- run de Autonomous Workforce por marca;
- AI specialists por domínio;
- camada Otto, Action Fabric/MCP Server, Workflow Data Fabric e Context Engine;
- etapas `Sense`, `Decide`, `Act` e `Govern`;
- guardrails de human-in-the-loop, least privilege, prompt-shield e sem log de PII;
- citações KB, Service Graph/CMDB e CAB;
- trilha preparada para auditoria `x_bank_ai_audit_event`.

O app iOS consome esse contrato via `ServiceNowClient` e também mantém fallback demo
para execução offline/simulador. A instância pode ser semeada com registros padrão
`incident` e `change_request` usando `servicenow/seed/seed-agentic-workflow.mjs`.

## Consequências

O demo fica visível em ServiceNow mesmo quando AI Agents nativos não estiverem
licenciados no tenant. Em produção, esse contrato deve ser ligado a Flow Designer,
AI Agent Orchestrator, AI Control Tower, ACLs do scoped app e auditoria real antes
de executar qualquer ação sensível.

LGPD: não registrar PII em logs ou respostas de agente.
CMN 4.893/2021: execução autônoma exige trilha, segregação e rollback.
Open Finance Brasil: consentimento precisa ser checado antes de comunicação ou ação CRM.
