// servicenow/scripted-rest/v1/mobile-agentic-workflow.js
//
// Endpoint:
//   GET  /api/x_bank/v1/mobile-agentic-workflow?brand=bradesco|itau
//   POST /api/x_bank/v1/mobile-agentic-workflow
//
// Expõe o run demo de Autonomous Workforce para o app mobile:
// Otto / Now Assist, AI specialists, AI Control Tower, CMDB, citações e guardrails.
//
// PII em log: PROIBIDO.

(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var SCRIPT_VERSION = '2026-05-agentic-v1';
    var MIN_CLIENT_VERSION = '0.1.0';

    var clientVersion  = request.getHeader('X-Client-Version')        || '0.0.0';
    var schemaHeader   = request.getHeader('X-Client-Schema-Version') || 'unknown';
    var clientPlatform = request.getHeader('X-Client-Platform')       || 'unknown';
    var brand          = readQueryParameter('brand', 'bradesco');
    var normalizedBrand = String(brand).toLowerCase();
    var isItau = normalizedBrand === 'itau';
    var segment = isItau ? 'Personnalité' : 'Prime';
    var payload = {};
    try {
        payload = request.body && request.body.data ? request.body.data : {};
    } catch (bodyReadError) {
        payload = {};
    }
    var requestedAction = payload.action || 'inspect';
    var humanApproved = requestedAction === 'approve_guardrail';

    gs.info('[mobile-v1][agentic] req received platform=' + clientPlatform +
            ' clientVersion=' + clientVersion +
            ' schemaHeader=' + schemaHeader +
            ' brand=' + normalizedBrand +
            ' action=' + requestedAction);

    var runId = isItau ? 'AWR-ITAU-P0-20260510' : 'AWR-BRAD-P1-20260510';
    var severity = isItau ? 'P0' : 'P1';
    var serviceName = isItau ? 'Core Pix Personnalité' : 'Pix Prime Mobile';

    var body = {
        schemaVersion: SCRIPT_VERSION,
        brand: normalizedBrand,
        controlPlane: {
            experience: 'ServiceNow Otto / Now Assist',
            valueChain: 'data -> decision -> action -> trust',
            systemOfAction: (isItau ? 'Itaú' : 'Bradesco') + ' ServiceNow Super App',
            controlTower: 'AI Control Tower + CMDB + audit trail'
        },
        run: {
            id: runId,
            title: isItau
                ? 'P0 Core Pix Personnalité com execução agentic governada'
                : 'P1 Pix Prime com contenção agentic governada',
            severity: severity,
            service: serviceName,
            businessImpact: isItau ? 'R$ 8,4 mi em valor protegido' : '42 cases Prime protegidos',
            status: humanApproved ? 'Guardrail aprovado; execução assistida liberada' : 'Aguardando aprovação humana',
            nextHumanDecision: isItau
                ? 'Aprovar change emergencial e comunicação executiva'
                : 'Aprovar contenção no gateway e playbook Prime',
            steps: [
                {
                    id: 'sense',
                    phase: 'Sense',
                    ownerAgent: 'AIOps AI Specialist',
                    action: isItau
                        ? 'Agrupar alertas do app, Pix, antifraude e mensageria'
                        : 'Agrupar latência do mobile gateway, Pix e antifraude',
                    evidence: 'CMDB Health 91, 7 relações órfãs, 18 CIs stale',
                    state: 'concluído',
                    requiresHumanApproval: false
                },
                {
                    id: 'decide',
                    phase: 'Decide',
                    ownerAgent: 'L1 Service Desk AI Specialist',
                    action: 'Classificar severidade, impacto, fila responsável e SLA',
                    evidence: isItau ? 'P0, cohort Personnalité, impacto executivo' : 'P1, Prime, SLA 18 min',
                    state: 'concluído',
                    requiresHumanApproval: false
                },
                {
                    id: 'act',
                    phase: 'Act',
                    ownerAgent: 'CRM Case Management AI Specialist',
                    action: 'Criar case CSM, rascunhar comunicação e preparar handoff',
                    evidence: 'Citações KB, histórico omnicanal e next best action',
                    state: humanApproved ? 'aprovado' : 'pronto',
                    requiresHumanApproval: true
                },
                {
                    id: 'govern',
                    phase: 'Govern',
                    ownerAgent: 'AI Control Tower',
                    action: 'Aplicar least privilege, prompt-shield, trilha auditável e rollback',
                    evidence: 'Política x_bank_ai_guardrail + CAB + LGPD',
                    state: humanApproved ? 'auditado' : 'aguardando humano',
                    requiresHumanApproval: true
                }
            ]
        },
        agents: [
            {
                id: 'aiops',
                name: 'AIOps AI Specialist',
                domain: 'IT Operations',
                permissionScope: 'Observability read + incident draft',
                currentWork: 'RCA contra CMDB, logs e eventos correlacionados'
            },
            {
                id: 'service-desk',
                name: 'L1 Service Desk AI Specialist',
                domain: 'ITSM',
                permissionScope: 'Incident triage + knowledge retrieval',
                currentWork: 'Triagem inicial, categorização, SLA e resumo'
            },
            {
                id: 'crm-case',
                name: 'CRM Case Management AI Specialist',
                domain: 'CRM / CSM',
                permissionScope: 'Case draft + customer update draft',
                currentWork: 'Comunicação ' + segment + ', case CSM e handoff'
            },
            {
                id: 'risk',
                name: 'Vulnerability Resolution AI Specialist',
                domain: 'Security & Risk',
                permissionScope: 'Risk evidence + change draft',
                currentWork: 'Guardrail, exceção, change e evidências'
            }
        ],
        platformSignals: [
            {
                id: 'otto',
                layer: 'Unified AI',
                title: 'Otto entende intenção e estado do trabalho',
                detail: 'Conversa vira plano com contexto, citação e próximos passos rastreáveis.',
                status: 'contexto pronto',
                symbolName: 'sparkles'
            },
            {
                id: 'action-fabric',
                layer: 'Action Fabric',
                title: 'MCP Server abre ações ServiceNow para agentes',
                detail: 'Incidente, mudança, catálogo, case CSM e CMDB expostos como tools com policy.',
                status: '4 packages',
                symbolName: 'point.3.connected.trianglepath.dotted'
            },
            {
                id: 'workflow-data-fabric',
                layer: 'Workflow Data Fabric',
                title: 'Context Engine cruza sinais internos e externos',
                detail: 'CMDB, observabilidade, CRM, atendimento ' + segment + ' e SPM viram contexto único.',
                status: 'sem copiar dados',
                symbolName: 'externaldrive.connected.to.line.below'
            },
            {
                id: 'control-tower',
                layer: 'AI Control Tower',
                title: 'Governança antes da execução autônoma',
                detail: 'Human-in-the-loop, prompt-shield, escopo mínimo e auditoria por run.',
                status: 'governado',
                symbolName: 'checkmark.shield.fill'
            }
        ],
        actionPackages: [
            {
                id: 'incident-bridge',
                title: isItau ? 'Abrir ponte P0' : 'Assumir war room P1',
                tool: 'x_bank.incident.bridge.open',
                target: isItau ? 'INC0018884' : 'INC0018885',
                guardrail: 'Somente cria ponte e resumo; não executa rollback.',
                state: 'ready'
            },
            {
                id: 'change-guardrail',
                title: 'Aprovar guardrail CAB',
                tool: 'x_bank.change.guardrail.approve',
                target: isItau ? 'CHG0030005' : 'CHG0030004',
                guardrail: 'Exige aprovação humana e plano de retorno.',
                state: 'human gate'
            },
            {
                id: 'csm-draft',
                title: isItau ? 'Draft CSM Personnalité' : 'Draft CSM Prime',
                tool: 'x_bank.csm.case.draft',
                target: 'case draft',
                guardrail: 'Rascunho com citação; envio final manual.',
                state: 'draft'
            },
            {
                id: 'cmdb-remediate',
                title: 'Plano CMDB Health',
                tool: 'x_bank.cmdb.health.remediate',
                target: '18 stale CIs',
                guardrail: 'Cria tarefas; não altera CI crítico sem owner.',
                state: 'planned'
            }
        ],
        controlMetrics: [
            {
                id: 'agent-risk',
                title: 'Agent risk',
                value: isItau ? 'médio' : 'baixo',
                detail: 'Escopo limita ação a rascunhos, ponte e aprovação guardada.'
            },
            {
                id: 'policy',
                title: 'Policy pass',
                value: '97%',
                detail: 'Prompt shield, PII logging off e trilha por correlation_id.'
            },
            {
                id: 'automation',
                title: 'Autonomia liberada',
                value: '62%',
                detail: 'Demais passos esperam humano por CAB, LGPD ou comunicação.'
            }
        ],
        governance: {
            humanInTheLoop: true,
            leastPrivilege: true,
            piiLoggingAllowed: false,
            promptInjectionShield: true,
            auditTrail: 'x_bank_ai_audit_event'
        },
        citations: [
            {
                id: 'kb',
                label: 'KB001928',
                source: 'Política de consentimento e comunicação digital'
            },
            {
                id: 'cmdb',
                label: 'Service Graph',
                source: 'CIs e relações críticas do fluxo Pix'
            },
            {
                id: 'cab',
                label: 'CHG004102',
                source: 'Plano de rollback e aprovação CAB'
            }
        ],
        compatibility: {
            minClientVersion: MIN_CLIENT_VERSION,
            receivedClientVersion: clientVersion,
            receivedSchemaHeader: schemaHeader,
            receivedPlatform: clientPlatform
        }
    };

    response.setStatus(200);
    response.setHeader('Content-Type', 'application/json');
    response.setHeader('X-Schema-Version', SCRIPT_VERSION);
    response.setHeader('Cache-Control', 'private, max-age=10');
    response.getStreamWriter().writeString(JSON.stringify(body));

    function readQueryParameter(name, fallback) {
        var value = fallback;
        try {
            value = request.getQueryParameter(name) || value;
        } catch (ignoredGetQueryError) {
            value = value;
        }
        try {
            if (request.queryParams && request.queryParams[name]) {
                value = request.queryParams[name];
                if (Object.prototype.toString.call(value) === '[object Array]') {
                    value = value[0];
                }
            }
        } catch (ignoredQueryParamsError) {
            value = value;
        }
        return value || fallback;
    }
})(request, response);
