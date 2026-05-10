// railway/services/bff-feature-flags/index.ts
//
// BFF de feature flags (low-latency edge fallback).
//
// Princípio: a fonte da verdade de feature flags é a instância ServiceNow.
// Este BFF é fallback para casos de:
//  - cliente em rede instável onde a instância está alta latência.
//  - flags de kill-switch que precisam de propagação imediata via CDN.
//  - emergência: instância indisponível e cliente precisa de defaults conhecidos.
//
// O BFF consome a instância via webhook + cache + ETag. Cliente iOS pergunta
// primeiro à instância; se >800ms ou erro, faz fallback para BFF.
//
// **Não é fonte da verdade.** Decisão de produto vem da instância sempre.

import Fastify from 'fastify';
import cors from '@fastify/cors';

const PORT = Number(process.env.PORT ?? 8080);
const SN_INSTANCE_URL = process.env.SERVICENOW_INSTANCE_URL ?? '';
const SN_OAUTH_TOKEN = process.env.SERVICENOW_OAUTH_TOKEN ?? '';
const CACHE_TTL_MS = Number(process.env.CACHE_TTL_MS ?? 30_000);

type Flags = {
  schemaVersion: string;
  flags: Record<string, boolean>;
  fetchedAt: number;
  source: 'servicenow' | 'cache' | 'static-fallback';
};

let cache: Flags | null = null;

const STATIC_FALLBACK: Flags = {
  schemaVersion: '2026-05-flags-v1',
  flags: {
    show_card_virtual: false,
    enable_pix_shortcut: true,
    enable_consent_center: true,
    enable_now_assist_chat: true,
    show_balance_by_default: false,
  },
  fetchedAt: 0,
  source: 'static-fallback',
};

async function fetchFromServiceNow(): Promise<Flags | null> {
  if (!SN_INSTANCE_URL) return null;
  try {
    const res = await fetch(
      `${SN_INSTANCE_URL}/api/x_bank/v1/mobile-feature-flags`,
      {
        headers: {
          Authorization: `Bearer ${SN_OAUTH_TOKEN}`,
          'X-Client-Platform': 'bff',
          'X-Client-Version': '0.0.0',
        },
        signal: AbortSignal.timeout(2000),
      }
    );
    if (!res.ok) return null;
    const json = (await res.json()) as { schemaVersion: string; featureFlags: Record<string, boolean> };
    return {
      schemaVersion: json.schemaVersion,
      flags: json.featureFlags,
      fetchedAt: Date.now(),
      source: 'servicenow',
    };
  } catch {
    return null;
  }
}

async function getFlags(): Promise<Flags> {
  const now = Date.now();
  if (cache && now - cache.fetchedAt < CACHE_TTL_MS) {
    return { ...cache, source: 'cache' };
  }
  const fresh = await fetchFromServiceNow();
  if (fresh) {
    cache = fresh;
    return fresh;
  }
  if (cache) return { ...cache, source: 'cache' };
  return STATIC_FALLBACK;
}

const app = Fastify({ logger: true });

await app.register(cors, {
  origin: [
    /\.bradesco\.com\.br$/,
    /\.itau\.com\.br$/,
    /^bradesco-app(-\w+)?:\/\//,
    /^itau-app(-\w+)?:\/\//,
  ],
});

app.get('/health', async () => ({ ok: true, ts: Date.now() }));

app.get('/v1/flags', async (req, reply) => {
  const clientVersion = String(req.headers['x-client-version'] ?? '0.0.0');
  const flags = await getFlags();

  reply
    .header('Cache-Control', 'public, max-age=15')
    .header('X-Flag-Source', flags.source)
    .header('X-Schema-Version', flags.schemaVersion);

  return {
    ...flags,
    compatibility: {
      receivedClientVersion: clientVersion,
      minClientVersion: '0.1.0',
    },
  };
});

// Webhook de invalidação chamado pela instância quando flags mudam.
// Autenticar com HMAC-SHA256 (secret compartilhado em env var).
app.post('/v1/invalidate', async (req, reply) => {
  // TODO: validar HMAC do header X-Sn-Signature antes de invalidar.
  cache = null;
  return reply.status(204).send();
});

app.listen({ host: '0.0.0.0', port: PORT });
