const { test, expect, request } = require('@playwright/test');
const { envValue, hasCredentials, requireEnv } = require('../support/env');
const { requireCredentialTierForTest } = require('../support/credentials');

const managerOnlyEndpoints = [
  {
    name: 'manager dashboard summary',
    path: '/api/method/jarz_pos.api.manager.get_manager_dashboard_summary',
    deniedPattern: /Manager Dashboard access required/i,
  },
  {
    name: 'shift monitor',
    path: '/api/method/jarz_pos.api.manager.get_pos_shift_monitor',
    deniedPattern: /Shift monitor access required/i,
  },
  {
    name: 'purchase suppliers',
    path: '/api/method/jarz_pos.api.purchase.get_suppliers',
    deniedPattern: /Managers only/i,
  },
  {
    name: 'cash transfer accounts',
    path: '/api/method/jarz_pos.api.cash_transfer.list_accounts',
    deniedPattern: /Managers only/i,
  },
  {
    name: 'stock transfer branches',
    path: '/api/method/jarz_pos.api.transfer.list_pos_profiles',
    deniedPattern: /Managers only/i,
  },
  {
    name: 'final products report',
    path: '/api/method/jarz_pos.api.reports.get_final_products_report',
    deniedPattern: /Only JARZ Manager can access reports/i,
  },
];

async function createAuthenticatedContext(baseURL, userEnv, passwordEnv) {
  const apiContext = await request.newContext({
    baseURL,
    extraHTTPHeaders: {
      Accept: 'application/json',
    },
  });

  const loginResponse = await apiContext.post('/api/method/login', {
    form: {
      usr: requireEnv(userEnv),
      pwd: requireEnv(passwordEnv),
    },
  });

  expect(loginResponse.ok()).toBeTruthy();
  return apiContext;
}

test.describe('Permission enforcement API', () => {
  test('staff is denied manager-only endpoints @staff @phase3', async ({}, testInfo) => {
    requireCredentialTierForTest('staff', testInfo);

    // A staff credential that resolves to the manager account proves nothing:
    // the endpoints would answer 200 and this spec would fail for the wrong
    // reason. That is exactly what the old E2E_USER -> STAGING_USER alias did.
    expect(
      envValue('E2E_USER').trim().toLowerCase(),
      'E2E_USER must be a real staff account, distinct from E2E_MANAGER_USER',
    ).not.toBe(envValue('E2E_MANAGER_USER').trim().toLowerCase());

    const apiContext = await createAuthenticatedContext(
      testInfo.project.use.baseURL,
      'E2E_USER',
      'E2E_PASSWORD',
    );

    try {
      for (const endpoint of managerOnlyEndpoints) {
        const response = await apiContext.get(endpoint.path);
        expect(response.status(), endpoint.name).toBe(403);
        expect(await response.text(), endpoint.name).toMatch(endpoint.deniedPattern);
      }
    } finally {
      await apiContext.dispose();
    }
  });

  test('manager can access manager-only endpoints @manager @phase3', async ({}, testInfo) => {
    // Was `!process.env.E2E_MANAGER_USER`, which read the RAW env and so
    // bypassed the E2E_MANAGER_USER -> STAGING_USER alias: with only the
    // documented STAGING_* defaults set, this test skipped every single run.
    // hasCredentials() resolves through the alias, so it now actually runs.
    requireCredentialTierForTest('manager', testInfo);

    const apiContext = await createAuthenticatedContext(
      testInfo.project.use.baseURL,
      'E2E_MANAGER_USER',
      'E2E_MANAGER_PASSWORD',
    );

    try {
      for (const endpoint of managerOnlyEndpoints) {
        const response = await apiContext.get(endpoint.path);
        expect(response.status(), endpoint.name).toBe(200);
        expect(await response.text(), endpoint.name).not.toHaveLength(0);
      }
    } finally {
      await apiContext.dispose();
    }
  });
});

// Guard against the whole file quietly degrading to "nothing ran".
test.describe('Permission enforcement coverage', () => {
  test('at least the staff and manager tiers are configured @meta', async () => {
    expect(
      hasCredentials('staff') || hasCredentials('manager'),
      'Neither the staff nor the manager credential tier is configured, so no ' +
        'permission boundary was exercised. See .env.e2e.example.',
    ).toBeTruthy();
  });
});
