const { test, expect } = require('@playwright/test');
const { loginThroughUi, startShiftIfRequired } = require('../support/auth');
const { requireCredentialTierForTest } = require('../support/credentials');

function waitForApiResponse(page, pathFragment, expectedStatus) {
  return page.waitForResponse(
    (response) =>
      response.url().includes(pathFragment) && response.status() === expectedStatus,
    { timeout: 30_000 },
  );
}

test.describe('Authenticated route access', () => {
  test('loads Sales Kanban data after the required shift flow @staff @phase1', async ({ page }, testInfo) => {
    requireCredentialTierForTest('staff', testInfo);

    await loginThroughUi(page);
    await startShiftIfRequired(page);

    const kanbanColumnsResponse = waitForApiResponse(
      page,
      '/api/method/jarz_pos.api.kanban.get_kanban_columns',
      200,
    );
    const kanbanInvoicesResponse = waitForApiResponse(
      page,
      '/api/method/jarz_pos.api.kanban.get_kanban_invoices',
      200,
    );

    await page.goto('/pos/#/kanban');
    await Promise.all([kanbanColumnsResponse, kanbanInvoicesResponse]);
    expect(page.url()).not.toContain('/login');
  });

  test('loads Manager Dashboard data when manager credentials are configured @manager @phase3', async ({ page }, testInfo) => {
    // Was `!process.env.E2E_MANAGER_USER`, which read the RAW env and so
    // bypassed the E2E_MANAGER_USER -> STAGING_USER alias: with only the
    // documented STAGING_* defaults set this test skipped every single run.
    requireCredentialTierForTest('manager', testInfo);

    await loginThroughUi(page, {
      userEnv: 'E2E_MANAGER_USER',
      passwordEnv: 'E2E_MANAGER_PASSWORD',
    });

    const managerSummaryResponse = waitForApiResponse(
      page,
      '/api/method/jarz_pos.api.manager.get_manager_dashboard_summary',
      200,
    );
    const managerOrdersResponse = waitForApiResponse(
      page,
      '/api/method/jarz_pos.api.manager.get_manager_orders',
      200,
    );
    const managerStatesResponse = waitForApiResponse(
      page,
      '/api/method/jarz_pos.api.manager.get_manager_states',
      200,
    );

    await page.goto('/pos/#/manager');
    await Promise.all([
      managerSummaryResponse,
      managerOrdersResponse,
      managerStatesResponse,
    ]);
    expect(page.url()).not.toContain('/login');
  });

  test('blocks staff access to the Manager Dashboard when opened directly @staff @phase1 @phase3', async ({ page }, testInfo) => {
    requireCredentialTierForTest('staff', testInfo);

    await loginThroughUi(page);
    await startShiftIfRequired(page);

    const managerSummaryForbidden = waitForApiResponse(
      page,
      '/api/method/jarz_pos.api.manager.get_manager_dashboard_summary',
      403,
    );

    await page.goto('/pos/#/manager');
    const response = await managerSummaryForbidden;

    expect(page.url()).not.toContain('/login');
    expect(JSON.stringify(await response.json())).toMatch(/Manager Dashboard access required/i);
  });

  test('blocks staff access to Purchase when opened directly @staff @phase1 @phase3', async ({ page }, testInfo) => {
    requireCredentialTierForTest('staff', testInfo);

    await loginThroughUi(page);
    await startShiftIfRequired(page);

    const purchaseForbidden = waitForApiResponse(
      page,
      '/api/method/jarz_pos.api.purchase.search_items',
      403,
    );

    await page.goto('/pos/#/purchase');
    const response = await purchaseForbidden;

    expect(page.url()).not.toContain('/login');
    expect(JSON.stringify(await response.json())).toMatch(/Managers only/i);
  });
});