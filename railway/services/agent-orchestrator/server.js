// railway/services/agent-orchestrator/server.js
//
// Ponte mínima para webhooks operacionais. O fluxo produtivo deve validar HMAC,
// allowlist de origem e segregação de dados antes de enviar tarefas a agentes.

import { createServer } from 'node:http';

const port = Number(process.env.PORT ?? 8080);

function json(res, statusCode, body) {
  res.writeHead(statusCode, {
    'content-type': 'application/json; charset=utf-8',
    'cache-control': 'no-store',
  });
  res.end(JSON.stringify(body));
}

function collectBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.setEncoding('utf8');
    req.on('data', (chunk) => {
      raw += chunk;
      if (raw.length > 64 * 1024) reject(new Error('payload_too_large'));
    });
    req.on('end', () => resolve(raw));
    req.on('error', reject);
  });
}

const server = createServer(async (req, res) => {
  if (req.method === 'GET' && req.url === '/health') {
    json(res, 200, { ok: true, ts: Date.now() });
    return;
  }

  if (req.method === 'POST' && req.url === '/v1/events') {
    try {
      const raw = await collectBody(req);
      json(res, 202, {
        accepted: true,
        bytes: raw.length,
        next: 'route_to_policy_checked_agent_queue',
      });
    } catch (error) {
      json(res, 413, { error: error.message });
    }
    return;
  }

  json(res, 404, { error: 'not_found' });
});

server.listen(port, '0.0.0.0');
