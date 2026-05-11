// servicenow/scripted-rest/v1/mobile-assist.js
//
// Endpoint:
//   POST /api/x_bank/v1/mobile-assist?brand=bradesco|itau
//
// Concierge gateway for the mobile super app.
// Production path: swap buildReply() with Virtual Agent API / Now Assist channel
// once the provider channel identity and Now Assist deployment are active.
//
// PII em log: PROIBIDO.

(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var SCRIPT_VERSION = '2026-05-assist-v1';
    var MIN_CLIENT_VERSION = '0.1.0';

    var clientVersion  = request.getHeader('X-Client-Version')        || '0.0.0';
    var schemaHeader   = request.getHeader('X-Client-Schema-Version') || 'unknown';
    var clientPlatform = request.getHeader('X-Client-Platform')       || 'unknown';
    var brand          = String(readQueryParameter('brand', 'bradesco')).toLowerCase();
    var isItau         = brand === 'itau';
    var payload        = readBody();
    var message        = String(payload.message || readQueryParameter('message', '') || '');
    var normalized     = message.toLowerCase();
    var context        = buildContext(isItau);
    var reply          = buildReply(normalized, context);

    gs.info('[mobile-v1][assist] req received platform=' + clientPlatform +
            ' clientVersion=' + clientVersion +
            ' schemaHeader=' + schemaHeader +
            ' brand=' + brand +
            ' intent=' + reply.intent);

    var body = {
        schemaVersion: SCRIPT_VERSION,
        brand: brand,
        provider: {
            displayName: 'Otto / Now Assist concierge',
            mode: 'instance_gateway',
            channel: 'mobile-superapp',
            connectionState: 'serviceNowInstance',
            nativeNowAssistPath: 'Virtual Agent API + Now Assist deployment channel',
            fallbackReason: 'Native Virtual Agent API was not exposed on this demo tenant during probe; this gateway preserves the same mobile contract.'
        },
        message: reply.text,
        operationalContext: context,
        nextActions: reply.actions,
        citations: buildCitations(isItau),
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
    response.setHeader('Cache-Control', 'private, max-age=5');
    response.getStreamWriter().writeString(JSON.stringify(body));

    function readBody() {
        try {
            return request.body && request.body.data ? request.body.data : {};
        } catch (ignoredBodyError) {
            return {};
        }
    }

    function buildContext(forItau) {
        return {
            severity: forItau ? 'P0' : 'P1',
            service: forItau ? 'Core Pix Personnalité' : 'Pix Prime Mobile',
            incident: forItau ? 'INC0018884' : 'INC0018885',
            change: forItau ? 'CHG0030005' : 'CHG0030004',
            runId: forItau ? 'AWR-ITAU-P0-20260510' : 'AWR-BRAD-P1-20260510',
            cmdbHealth: '91',
            pendingApprovals: '2',
            customerImpact: forItau ? 'Personnalité executive cohort' : 'Prime agencies and digital support',
            nextHumanDecision: forItau
                ? 'Approve emergency change and executive communication'
                : 'Approve gateway containment and Prime agency playbook'
        };
    }

    function buildReply(text, ctx) {
        if (containsAny(text, ['p0', 'p1', 'incidente', 'war room', 'ponte'])) {
            return {
                intent: 'critical_incident',
                text: 'Estou conectado ao ServiceNow pelo Mobile Assist Gateway. O foco agora é ' +
                    ctx.severity + ' em ' + ctx.service + ': CMDB Health ' + ctx.cmdbHealth +
                    ', incidente ' + ctx.incident + ', mudança ' + ctx.change +
                    ' e decisão humana pendente. Posso abrir a ponte, montar resumo executivo, criar draft CSM/CRM e deixar a execução autônoma parada no guardrail.',
                actions: criticalActions(ctx)
            };
        }

        if (containsAny(text, ['cmdb', 'health', 'ci', 'depend'])) {
            return {
                intent: 'cmdb_health',
                text: 'CMDB Health está em ' + ctx.cmdbHealth +
                    '. Antes de qualquer automação eu usaria Service Graph, CIs stale, relações órfãs e owner do serviço para limitar escopo, risco e rollback. A recomendação é criar plano CMDB Health e só liberar alteração crítica com owner validado.',
                actions: [
                    action('open_cmdb_health', 'Abrir saúde CMDB', 'Ver CIs, relações órfãs e owner do serviço.', 'CMDB', false, 'externaldrive.connected.to.line.below'),
                    action('create_remediation_plan', 'Criar plano de correção', 'Gerar tarefas sem alterar CI crítico automaticamente.', 'ITOM', true, 'checkmark.shield.fill')
                ]
            };
        }

        if (containsAny(text, ['aprovar', 'approve', 'guardrail', 'change', 'mudança', 'mudanca'])) {
            return {
                intent: 'approval',
                text: 'A decisão que pede sua aprovação é: ' + ctx.nextHumanDecision +
                    '. Eu trouxe evidência do incidente, CMDB, rollback, impacto ao cliente e CAB. A execução continua human-in-the-loop; nenhum rollback, comunicação ou alteração de CI sai sem sua confirmação.',
                actions: [
                    action('approve_guardrail', 'Aprovar guardrail', 'Libera somente a etapa governada do run ' + ctx.runId + '.', 'Change', true, 'person.badge.shield.checkmark.fill'),
                    action('review_evidence', 'Revisar evidências', 'Abrir citações KB, CAB, CMDB e impacto CSM.', 'Audit', false, 'doc.text.magnifyingglass')
                ]
            };
        }

        if (containsAny(text, ['action fabric', 'workflow data', 'mcp', 'agentic', 'autonom', 'specialist', 'workflow'])) {
            return {
                intent: 'agentic_workflow',
                text: 'O mordomo está usando o contrato de Autonomous Workflow: Sense com AIOps, Decide com Service Desk AI Specialist, Act com CRM/CSM AI Specialist e Govern com AI Control Tower. Action Fabric expõe tools como ponte, guardrail CAB, case CSM e plano CMDB; Workflow Data Fabric entrega contexto sem copiar dados.',
                actions: [
                    action('inspect_run', 'Ver run autônomo', 'Abrir ' + ctx.runId + ' com steps, agentes e risco.', 'Autonomous Workflow', false, 'point.3.connected.trianglepath.dotted'),
                    action('approve_guardrail', 'Aprovar próximo passo', 'Somente depois da revisão humana.', 'AI Control Tower', true, 'checkmark.shield.fill')
                ]
            };
        }

        if (containsAny(text, ['csm', 'crm', 'cliente', 'agência', 'agencia', 'prime', 'personnalité', 'personnalite'])) {
            return {
                intent: 'customer_operations',
                text: 'Para experiência do cliente eu separaria três frentes: case CSM preventivo, CRM com next best action e comunicação operacional auditada. O banco continua sem ação financeira aqui; o app orquestra trabalho ServiceNow e registra evidências.',
                actions: [
                    action('draft_csm_case', 'Criar draft CSM', 'Rascunho com impacto, cohort e SLA.', 'CSM', true, 'person.2.badge.gearshape.fill'),
                    action('prepare_crm_brief', 'Preparar CRM brief', 'Next best action para atendimento executivo.', 'CRM', false, 'bubble.left.and.text.bubble.right.fill')
                ]
            };
        }

        return {
            intent: 'daily_brief',
            text: 'Bom dia. Seu cockpit ServiceNow tem ' + ctx.severity + ' em ' + ctx.service +
                ', ' + ctx.pendingApprovals + ' aprovações, CMDB Health ' + ctx.cmdbHealth +
                ', um run autônomo aguardando você e impacto ' + ctx.customerImpact +
                '. Minha recomendação: revisar evidências, aprovar ou segurar o guardrail e mandar o resumo executivo para a war room.',
            actions: criticalActions(ctx)
        };
    }

    function criticalActions(ctx) {
        return [
            action('open_incident_bridge', 'Abrir ponte executiva', 'Convidar times com contexto do incidente ' + ctx.incident + '.', 'ITSM', false, 'dot.radiowaves.left.and.right'),
            action('approve_guardrail', 'Aprovar guardrail', ctx.nextHumanDecision + '.', 'Change', true, 'person.badge.shield.checkmark.fill'),
            action('draft_csm_case', 'Draft CSM/CRM', 'Preparar comunicação sem envio automático.', 'CSM / CRM', true, 'rectangle.and.pencil.and.ellipsis'),
            action('open_cmdb_health', 'Ver CMDB Health', 'Validar dependências antes da ação.', 'CMDB', false, 'waveform.path.ecg')
        ];
    }

    function action(id, title, detail, system, requiresApproval, symbolName) {
        return {
            id: id,
            title: title,
            detail: detail,
            system: system,
            requiresApproval: requiresApproval,
            symbolName: symbolName
        };
    }

    function buildCitations(forItau) {
        return [
            {
                id: 'incident',
                label: forItau ? 'INC0018884' : 'INC0018885',
                source: forItau ? 'P0 Core Pix Personnalité' : 'P1 Pix Prime Mobile'
            },
            {
                id: 'change',
                label: forItau ? 'CHG0030005' : 'CHG0030004',
                source: 'CAB, rollback e aprovação humana'
            },
            {
                id: 'cmdb',
                label: 'Service Graph',
                source: 'CMDB Health, CIs e relações críticas'
            }
        ];
    }

    function containsAny(value, terms) {
        for (var i = 0; i < terms.length; i += 1) {
            if (value.indexOf(terms[i]) >= 0) {
                return true;
            }
        }
        return false;
    }

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
