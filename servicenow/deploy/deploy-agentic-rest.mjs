#!/usr/bin/env node
// Deploy mobile Scripted REST resources to a ServiceNow instance.
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
const auth = Buffer.from(`${username}:${password}`).toString('base64');

const resources = [
  {
    name: 'mobile-agentic-workflow',
    relativePath: '/mobile-agentic-workflow',
    methods: ['GET', 'POST'],
    requiresAuthentication: true,
    shortDescription: 'Autonomous Workforce run for the mobile super app',
    scriptPath: path.join(repoRoot, 'servicenow/scripted-rest/v1/mobile-agentic-workflow.js'),
  },
  {
    name: 'mobile-assist',
    relativePath: '/mobile-assist',
    methods: ['POST'],
    requiresAuthentication: false,
    shortDescription: 'Read-only mobile concierge gateway for Now Assist demo',
    scriptPath: path.join(repoRoot, 'servicenow/scripted-rest/v1/mobile-assist.js'),
  },
];

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

for (const resource of resources) {
  const script = await readFile(resource.scriptPath, 'utf8');

  for (const method of resource.methods) {
    await upsert(
      'sys_ws_operation',
      `web_service_definition=${api.sys_id}^name=${resource.name} ${method}`,
      {
        name: `${resource.name} ${method}`,
        web_service_definition: api.sys_id,
        web_service_version: version.sys_id,
        http_method: method,
        relative_path: resource.relativePath,
        operation_uri: resource.relativePath,
        active: true,
        requires_authentication: resource.requiresAuthentication,
        requires_acl_authorization: false,
        consumes: 'application/json',
        produces: 'application/json',
        operation_script: script,
        short_description: resource.shortDescription,
      }
    );
  }
}

console.log(
  JSON.stringify({
    api: api.sys_id,
    version: version.sys_id,
    endpoints: resources.map((resource) => `${instanceUrl}/api/x_bank/v1${resource.relativePath}`),
  })
);
