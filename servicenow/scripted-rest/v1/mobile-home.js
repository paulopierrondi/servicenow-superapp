// servicenow/scripted-rest/v1/mobile-home.js
//
// Endpoint: GET /api/x_bank/v1/mobile-home
//
// Retorna o payload do command center ServiceNow-first do app nativo multi-tenant.
// Versionado por path; futura v2 convive com v1 (ADR-004).
//
// Headers obrigatórios (lidos):
//   X-Client-Version          → versão do binário iOS
//   X-Client-Schema-Version   → versão de schema esperada pelo cliente
//   X-Client-Platform         → ios | android | bff
//
// Response sempre inclui:
//   schemaVersion             → versão do schema retornado
//   featureFlags              → flags server-side
//   compatibility             → minClientVersion, headers ecoados
//   cards                     → cards do super app (workspaces, catálogo, trust, assist)
//
// Princípios:
//   - Nunca quebrar v1 em produção (ADR-004).
//   - Bump de schemaVersion quando adicionar/remover campo.
//   - Logs com prefixo [mobile-v1].
//   - PII em log: PROIBIDO.

(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var SCRIPT_VERSION = '2026-05-home-v1';
    var MIN_CLIENT_VERSION = '0.1.0';

    var clientVersion  = request.getHeader('X-Client-Version')        || '0.0.0';
    var schemaHeader   = request.getHeader('X-Client-Schema-Version') || 'unknown';
    var clientPlatform = request.getHeader('X-Client-Platform')       || 'unknown';

    gs.info('[mobile-v1][home] req received platform=' + clientPlatform +
            ' clientVersion=' + clientVersion +
            ' schemaHeader=' + schemaHeader);

    // Feature flags consultadas da tabela x_bank_feature_flag.
    // GlideRecord stub no mock harness retorna defaults; em prod, lê real.
    var featureFlags = readFeatureFlags();

    var body = {
        schemaVersion: SCRIPT_VERSION,
        featureFlags: featureFlags,
        cards: [
            {
                id: 'workspaces',
                title: 'Workspaces',
                subtitle: 'ITSM, SPM, CSM e CRM',
                action: 'open_workspaces'
            },
            {
                id: 'catalog',
                title: 'Catálogo vivo',
                subtitle: 'Orquestração por intenção',
                action: 'open_catalog'
            },
            {
                id: 'trust',
                title: 'Trust center',
                subtitle: 'Consentimento, LGPD e auditoria',
                action: 'open_security'
            },
            {
                id: 'assist',
                title: 'Now Assist',
                subtitle: 'AI operacional com contexto',
                action: 'open_support',
                requires_flag: 'enable_now_assist_chat'
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

    function readFeatureFlags() {
        var flags = {
            show_card_virtual: false,
            enable_pix_shortcut: true,
            enable_consent_center: false,
            enable_now_assist_chat: false,
            show_balance_by_default: false
        };
        try {
            var gr = new GlideRecord('x_bank_feature_flag');
            gr.addQuery('active', true);
            gr.query();
            while (gr.next()) {
                var key = gr.getValue('flag_key');
                var val = gr.getValue('flag_value');
                if (key) flags[key] = (val === 'true' || val === true);
            }
        } catch (e) {
            gs.warn('[mobile-v1][home] feature flag table read failed: ' + e.message);
        }
        return flags;
    }
})(request, response);
