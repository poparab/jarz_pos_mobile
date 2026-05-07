const { test, expect, request } = require('@playwright/test');
const { requireEnv } = require('../support/env');

const managerOnlyEndpoints = [
  {
    name: 'manager dashboard summary',
    path: '/api/method/jarz_pos.api.manager.get_manager_dashboard_summary',
    deniedPattern: /Manager Dashboard access required/i,
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
  test('staff is denied manager-only endpoints', async ({}, testInfo) => {
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

  test('manager can access manager-only endpoints', async ({}, testInfo) => {
    test.skip(
      !process.env.E2E_MANAGER_USER || !process.env.E2E_MANAGER_PASSWORD,
      'Set E2E_MANAGER_USER and E2E_MANAGER_PASSWORD to run manager-only API checks.',
    );

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