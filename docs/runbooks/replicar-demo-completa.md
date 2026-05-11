# Replicar demo completa Itaú e Bradesco

Este runbook gera duas demos verticais em MP4:

- Itaú: executivo + fulfiller, P0 Core Pix Personnalité.
- Bradesco: executivo + fulfiller, P1 Pix Prime Mobile.

## Pré-requisitos

- macOS com Node.js 22+.
- FFmpeg disponível no PATH.
- Google Chrome instalado para o render do HyperFrames.
- Xcode para validar o app iOS, quando necessário.

Validar ambiente:

```bash
npx --yes hyperframes@0.5.7 doctor
make ios-build
make contract-test
```

## Gerar vídeos

```bash
make demo-videos
```

Saídas:

```text
deliverables/itau-demo/itau-servicenow-superapp-complete-demo.mp4
deliverables/bradesco-demo/bradesco-servicenow-superapp-complete-demo.mp4
```

O comando cria também os projetos HyperFrames replicáveis em:

```text
deliverables/demo-complete/itau/
deliverables/demo-complete/bradesco/
```

Cada projeto contém `DESIGN.md`, `index.html`, `package.json`, `hyperframes.json` e `meta.json`.

## Narrativas

### Executivo

1. Entra no app com visual de banco final.
2. Vê alerta P0/P1 como item operacional do dia.
3. Pergunta ao mordomo Otto / Now Assist.
4. Recebe resumo com incidente, change, CMDB Health, impacto CSM/CRM e próxima decisão.
5. Aprova o guardrail ou segura a execução.

### Fulfiller

1. Recebe o handoff do mesmo run.
2. Assume war room ou ponte executiva.
3. Valida CMDB Health e dependências de serviço.
4. Prepara ITSM, CSM, CRM e SPM no mesmo fluxo.
5. Mantém execução autônoma governada pelo AI Control Tower.

## Reapontar para outra instância

Os vídeos mostram o contrato mobile já usado pelo app:

```text
/api/x_bank/v1/mobile-assist
/api/x_bank/v1/mobile-agentic-workflow
```

Para instalar em outra instância:

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

Não grave credenciais no repositório.
