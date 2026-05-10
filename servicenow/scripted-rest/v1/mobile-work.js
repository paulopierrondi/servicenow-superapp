// servicenow/scripted-rest/v1/mobile-work.js
//
// Endpoint: GET /api/x_bank/v1/mobile-work
//
// Retorna a visão operacional ServiceNow para o app mobile multi-marca:
// ITSM, SPM, CSM, CRM e sinais preparados para Now Assist.
//
// PII em log: PROIBIDO.

(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var SCRIPT_VERSION = '2026-05-work-v1';
    var MIN_CLIENT_VERSION = '0.1.0';

    var clientVersion  = request.getHeader('X-Client-Version')        || '0.0.0';
    var schemaHeader   = request.getHeader('X-Client-Schema-Version') || 'unknown';
    var clientPlatform = request.getHeader('X-Client-Platform')       || 'unknown';
    var brand          = request.getQueryParameter('brand')           || 'bradesco';
    var normalizedBrand = String(brand).toLowerCase();
    var isItau = normalizedBrand === 'itau';
    var segment = isItau ? 'Personnalité' : 'Prime';
    var manager = isItau ? 'Marina Costa' : 'Camila Andrade';

    gs.info('[mobile-v1][work] req received platform=' + clientPlatform +
            ' clientVersion=' + clientVersion +
            ' schemaHeader=' + schemaHeader +
            ' brand=' + brand);

    var body = {
        schemaVersion: SCRIPT_VERSION,
        brand: brand,
        nowAssist: {
            enabled: true,
            capabilities: [
                'answer_with_citations',
                'voice_search',
                'offline_action_queue',
                'summarize_incident',
                'draft_customer_update',
                'prioritize_demand',
                'explain_project_risk'
            ]
        },
        launcher: [
            {
                id: 'it-laptop',
                title: 'Solicitar notebook',
                department: 'TI',
                action: 'open_catalog_item'
            },
            {
                id: 'facilities-room',
                title: 'Reservar sala segura',
                department: 'Facilities',
                action: 'open_workspace_reservation'
            },
            {
                id: 'finance-card',
                title: 'Cartão corporativo',
                department: 'Financeiro',
                action: 'open_request'
            },
            {
                id: 'legal-nda',
                title: 'NDA fornecedor',
                department: 'Jurídico',
                action: 'open_legal_flow'
            },
            {
                id: 'hr-profile',
                title: 'Atualizar perfil',
                department: 'RH',
                action: 'open_profile_update'
            }
        ],
        actionItems: [
            {
                id: 'APR000812',
                title: 'Aprovar mudança mobile',
                due: 'Hoje 17:00',
                riskLevel: 'Médio'
            },
            {
                id: 'TASK004219',
                title: 'Revisar evidência LGPD',
                due: 'Amanhã',
                riskLevel: 'Alto'
            }
        ],
        customerExperience: {
            csm: [
                {
                    id: 'csm-pix-case',
                    title: 'Caso Pix contestado',
                    metric: 'SLA 18 min',
                    owner: 'CSM',
                    signal: 'Case CSM com histórico omnicanal, SLA e evidências do journey twin'
                },
                {
                    id: 'csm-manager-handoff',
                    title: 'Handoff para gerente',
                    metric: '1 thread',
                    owner: segment,
                    signal: 'Now Assist preserva contexto, consentimento e próximos passos para ' + manager
                },
                {
                    id: 'csm-voice-of-customer',
                    title: 'Voz do cliente',
                    metric: 'NPS +12',
                    owner: 'CX',
                    signal: 'Reclamação, NPS, causa raiz e incidente conectados antes da resposta final'
                }
            ],
            crm: [
                {
                    id: 'crm-next-best-action',
                    title: isItau ? 'Next best action Personnalité' : 'Next best action Prime',
                    metric: 'NBA',
                    owner: 'CRM',
                    signal: 'Oferta explicável com consentimento, propensão, elegibilidade e limite operacional'
                },
                {
                    id: 'crm-relationship-360',
                    title: isItau ? 'Relacionamento Itaú 360' : 'Relacionamento Bradesco 360',
                    metric: '360',
                    owner: brand,
                    signal: isItau
                        ? 'Perfil, momento de vida, cartões, íon e atendimento priorizados em uma visão CRM'
                        : 'Carteira, cartões, seguros, investimentos e atendimento priorizados em uma visão CRM'
                }
            ]
        },
        synthesizedAnswer: {
            question: 'Como revisar consentimento Open Finance?',
            citation: 'KB001928',
            requiresHumanReview: true
        },
        journeyTwin: {
            id: 'JTW-2026-0510',
            title: 'Pix contestado sem abrir chamado manual',
            minutesSaved: '42 min',
            riskDelta: '-31%',
            nodes: [
                { id: 'customer', label: 'Cliente', owner: brand },
                { id: 'consent', label: 'Consentimento', owner: 'LGPD' },
                { id: 'risk', label: 'Risco', owner: 'ZTA' },
                { id: 'assist', label: 'Now Assist', owner: 'AI' },
                { id: 'itsm', label: 'ITSM', owner: 'SRE' },
                { id: 'spm', label: 'SPM', owner: 'Portfólio' },
                { id: 'audit', label: 'Auditoria', owner: 'GRC' }
            ],
            policy: {
                requiresHumanReview: true,
                piiLoggingAllowed: false,
                immutableAuditTrail: true
            }
        },
        workspaces: {
            itsm: [
                {
                    id: 'INC0012487',
                    category: 'Incidente',
                    title: 'Alta latência no Pix',
                    status: 'Em contenção',
                    priority: 'P1',
                    owner: 'SRE Mobile',
                    due: 'SLA 18 min',
                    signal: 'Now Assist preparou causa provável e próximos passos'
                },
                {
                    id: 'RITM009812',
                    category: 'Requisição',
                    title: 'Cartão virtual corporativo',
                    status: 'Aguardando automação',
                    priority: 'P3',
                    owner: 'Operações cartões',
                    due: 'Hoje',
                    signal: 'Pronto para fulfill via Flow Designer'
                },
                {
                    id: 'CHG004102',
                    category: 'Mudança',
                    title: 'Janela mobile backend',
                    status: 'Aprovada',
                    priority: 'P2',
                    owner: 'CAB Digital',
                    due: '12 mai',
                    signal: 'Risco baixo, plano de reversão validado'
                }
            ],
            spm: [
                {
                    id: 'DMND000731',
                    category: 'Demanda',
                    title: 'Consent hub Open Finance',
                    status: 'Priorizada',
                    priority: 'Valor alto',
                    owner: 'Portfólio digital',
                    due: 'Q2',
                    signal: 'Now Assist resumiu dependências e benefícios esperados'
                },
                {
                    id: 'PRJ001927',
                    category: 'Projeto',
                    title: 'ZTA Mobile',
                    status: 'Verde',
                    priority: 'Estratégico',
                    owner: 'Cyber + Canais',
                    due: '72%',
                    signal: 'Desvio de prazo dentro da tolerância'
                },
                {
                    id: 'RISK000442',
                    category: 'Risco',
                    title: 'Residência de dados Railway',
                    status: 'Mitigando',
                    priority: 'Regulatório',
                    owner: 'GRC',
                    due: '16 mai',
                    signal: 'Controle exige revisão jurídica antes de produção'
                }
            ]
        },
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
})(request, response);
