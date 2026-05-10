#!/usr/bin/env node
// Seed demo records in a ServiceNow instance for the mobile agentic workflow.
//
// Required env:
//   SN_INSTANCE_URL=https://example.service-now.com
//   SN_USERNAME=admin
//   SN_PASSWORD=...
//
// The script intentionally creates standard Incident and Change records only.
// It does not require Now Assist, AI Agents or CSM plugins to be licensed.

const instanceUrl = process.env.SN_INSTANCE_URL;
const username = process.env.SN_USERNAME;
const password = process.env.SN_PASSWORD;

if (!instanceUrl || !username || !password) {
  console.error('Missing SN_INSTANCE_URL, SN_USERNAME or SN_PASSWORD');
  process.exit(1);
}

const auth = Buffer.from(`${username}:${password}`).toString('base64');

const runs = [
  {
    brand: 'Bradesco',
    id: 'AWR-BRAD-P1-20260510',
    severity: 'P1',
    service: 'Pix Prime Mobile',
    impact: '2',
    urgency: '2',
    risk: '3',
    description:
      'AIOps AI Specialist correlaciona CMDB, L1 Service Desk triagem, CRM Case Management prepara CSM e AI Control Tower segura execução até aprovação humana.',
  },
  {
    brand: 'Itaú',
    id: 'AWR-ITAU-P0-20260510',
    severity: 'P0',
    service: 'Core Pix Personnalité',
    impact: '1',
    urgency: '1',
    risk: '2',
    description:
      'AIOps AI Specialist correlaciona Pix, app, antifraude e mensageria; CRM Case Management prepara comunicação Personnalité; AI Control Tower governa execução.',
  },
];

async function tablePost(table, body) {
  const response = await fetch(`${instanceUrl}/api/now/table/${table}`, {
    method: 'POST',
    headers: {
      authorization: `Basic ${auth}`,
      accept: 'application/json',
      'content-type': 'application/json',
    },
    body: JSON.stringify(body),
  });

  const payload = await response.json();
  if (!response.ok) {
    throw new Error(`${table} failed ${response.status}: ${JSON.stringify(payload)}`);
  }
  return payload.result;
}

for (const run of runs) {
  const incident = await tablePost('incident', {
    short_description: `${run.id} | ${run.brand} ${run.service} agentic workflow`,
    description: `Demo ServiceNow Super App: Autonomous Workforce run exposto pelo app. ${run.description}`,
    impact: run.impact,
    urgency: run.urgency,
    category: 'software',
    contact_type: 'monitoring',
    correlation_id: run.id,
  });

  const change = await tablePost('change_request', {
    short_description: `CHG | ${run.id} guardrail approval`,
    description:
      `Demo change criado pelo ServiceNow Super App para mostrar aprovação humana antes do autonomous workflow executar contenção ${run.service}.`,
    impact: run.impact,
    urgency: run.urgency,
    risk: run.risk,
    correlation_id: run.id,
  });

  console.log(
    JSON.stringify({
      run: run.id,
      incident: incident.number,
      change: change.number,
      query: `${instanceUrl}/nav_to.do?uri=task_list.do?sysparm_query=correlation_id=${run.id}`,
    })
  );
}
