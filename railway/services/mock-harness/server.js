// railway/services/mock-harness/server.js
//
// Mock harness ServiceNow Scripted REST.
// Permite ao agente, ao CI e a sessões locais de iOS rodar contract tests
// sem depender da instância ServiceNow real.
//
// Princípio: este servidor importa e executa os arquivos JS reais de
// servicenow/scripted-rest/v{N}/*.js dentro de um harness que mocka os globals
// usados por ServiceNow (gs, GlideRecord, GlideAjax, etc.) com superfície mínima.
//
// O agente NÃO deve estender a superfície sem ADR. Mocks crescentes viram
// fonte de divergência entre teste e produção.

import Fastify from 'fastify';
import path from 'node:path';
import { readFile, readdir, stat } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SCRIPTED_REST_ROOT = path.resolve(
  __dirname,
  '../../../servicenow/scripted-rest'
);

// --- Mock dos globals ServiceNow (superfície mínima) ---
function buildMockGlobals(consoleLog) {
  return {
    gs: {
      info: (msg) => consoleLog('info', msg),
      warn: (msg) => consoleLog('warn', msg),
      error: (msg) => consoleLog('error', msg),
      getUserID: () => 'mock-user-id',
      getUserName: () => 'mock-user',
      nowDateTime: () => new Date().toISOString(),
    },
    // GlideRecord stub — qualquer query retorna vazio.
    // Para testes que exigem dados, popular via fixture específico do contract test.
    GlideRecord: function (table) {
      this.table = table;
      this.query = () => {};
      this.next = () => false;
      this.getValue = () => null;
      this.getDisplayValue = () => null;
      this.addQuery = () => {};
      this.setLimit = () => {};
    },
    // Fixture loader: contract tests podem pre-carregar registros simulados
    // via header X-Mock-Fixture: <fixture-name>.
  };
}

// --- HTTP harness ---
function buildRequest(req, body) {
  return {
    getHeader: (name) => req.headers[name.toLowerCase()] ?? null,
    getQueryParameter: (name) => req.query[name] ?? null,
    body: { data: body },
    pathParams: req.params,
  };
}

function buildResponse() {
  let status = 200;
  const headers = {};
  const chunks = [];
  return {
    setStatus: (s) => { status = s; },
    setHeader: (k, v) => { headers[k] = v; },
    getStreamWriter: () => ({
      writeString: (s) => { chunks.push(s); }
    }),
    _result: () => ({ status, headers, body: chunks.join('') }),
  };
}

// --- Carregar e executar Scripted REST file ---
async function loadAndRun(scriptedRestFile, req, body, logCollector) {
  const code = await readFile(scriptedRestFile, 'utf8');

  const globals = buildMockGlobals((level, msg) => {
    logCollector.push({ level, msg, ts: Date.now() });
  });

  const request = buildRequest(req, body);
  const response = buildResponse();

  const sandbox = {
    ...globals,
    request,
    response,
    JSON,
    console: { log: (...a) => logCollector.push({ level: 'log', msg: a.join(' '), ts: Date.now() }) },
  };

  const ctx = vm.createContext(sandbox);
  const wrapped = `(function() {\n${code}\n}).call(this);`;
  vm.runInContext(wrapped, ctx, { timeout: 5000 });

  return response._result();
}

// --- Setup Fastify ---
const app = Fastify({
  logger: { level: process.env.LOG_LEVEL ?? 'info' },
});

app.get('/health', async () => ({ ok: true, ts: Date.now() }));

app.get('/_meta/scripts', async () => {
  const versions = await readdir(SCRIPTED_REST_ROOT);
  const out = {};
  for (const v of versions) {
    const dir = path.join(SCRIPTED_REST_ROOT, v);
    const s = await stat(dir);
    if (!s.isDirectory()) continue;
    out[v] = (await readdir(dir)).filter((f) => f.endsWith('.js'));
  }
  return out;
});

// Roteamento dinâmico para /api/x_bank/v{N}/{resource}
app.all('/api/x_bank/:version/:resource', async (req, reply) => {
  const { version, resource } = req.params;
  const file = path.join(SCRIPTED_REST_ROOT, version, `${resource}.js`);

  try {
    await stat(file);
  } catch {
    return reply.status(404).send({
      error: 'script_not_found',
      version,
      resource,
      hint: `Crie ${file} ou cheque /_meta/scripts`,
    });
  }

  const logs = [];
  try {
    const result = await loadAndRun(file, req, req.body, logs);
    Object.entries(result.headers).forEach(([k, v]) => reply.header(k, v));
    return reply.status(result.status).send(result.body);
  } catch (e) {
    return reply.status(500).send({
      error: 'mock_harness_failure',
      message: e.message,
      stack: e.stack,
      logs,
    });
  }
});

const port = parseInt(process.env.PORT ?? '8080', 10);
app.listen({ host: '0.0.0.0', port }, (err) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
});
