#!/usr/bin/env node
// Deploy the mobile agentic workflow Scripted REST resource to a ServiceNow instance.
//
// Required env:
//   SN_INSTANCE_URL=https://example.service-now.com
//   SN_USERNAME=admin
//   SN_PASSWORD=...

import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const instanceUrl = process.env.SN_INSTANCE_URL;
const username = process.env.SN_USERNAME;
const password = process.env.SN_PASSWORD;

if (!instanceUrl || !username || !password) {
  console.error('Missing SN_INSTANCE_URL, SN_USERNAME or SN_PASSWORD');
  process.exit(1);
}

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..', '..');
const scriptPath = path.join(
  repoRoot,
  'servicenow/scripted-rest/v1/mobile-agentic-workflow.js'
);
const script = await readFile(scriptPath, 'utf8');
const auth = Buffer.from(`${username}:${password}`).toString('base64');

async function table(method, tableName, body, query = '', sysId = '') {
  const url = new URL(`${instanceUrl}/api/now/table/${tableName}${sysId ? `/${sysId}` : ''}`);
  if (query) {
    url.searchParams.set('sysparm_query', query);
    url.searchParams.set('sysparm_limit', '1');
  }

  const response = await fetch(url, {
    method,
    headers: {
      authorization: `Basic ${auth}`,
      accept: 'application/json',
      'content-type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  const payload = await response.json();
  if (!response.ok) {
    throw new Error(`${method} ${tableName} failed ${response.status}: ${JSON.stringify(payload)}`);
  }
  return payload.result;
}

async function upsert(tableName, query, body) {
  const existing = await table('GET', tableName, null, query);
  if (Array.isArray(existing) && existing.length > 0) {
    return table('PATCH', tableName, body, '', existing[0].sys_id);
  }
  return table('POST', tableName, body);
}

const api = await upsert('sys_ws_definition', 'namespace=x_bank^service_id=v1', {
  name: 'x_bank mobile v1',
  namespace: 'x_bank',
  service_id: 'v1',
  active: true,
  short_description: 'Mobile ServiceNow Super App APIs',
  consumes: 'application/json',
  produces: 'application/json',
});

const version = await upsert(
  'sys_ws_version',
  `web_service_definition=${api.sys_id}^version_id=v1`,
  {
    web_service_definition: api.sys_id,
    version_id: 'v1',
    version: '1',
    is_default: true,
    active: true,
    short_description: 'v1 mobile API',
  }
);

for (const method of ['GET', 'POST']) {
  await upsert(
    'sys_ws_operation',
    `web_service_definition=${api.sys_id}^name=mobile-agentic-workflow ${method}`,
    {
      name: `mobile-agentic-workflow ${method}`,
      web_service_definition: api.sys_id,
      web_service_version: version.sys_id,
      http_method: method,
      relative_path: '/mobile-agentic-workflow',
      operation_uri: '/mobile-agentic-workflow',
      active: true,
      requires_authentication: true,
      requires_acl_authorization: false,
      consumes: 'application/json',
      produces: 'application/json',
      operation_script: script,
      short_description: 'Autonomous Workforce run for the mobile super app',
    }
  );
}

console.log(
  JSON.stringify({
    api: api.sys_id,
    version: version.sys_id,
    endpoint: `${instanceUrl}/api/x_bank/v1/mobile-agentic-workflow?brand=itau`,
  })
);
