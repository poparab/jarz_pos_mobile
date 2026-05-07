const { test, expect } = require('@playwright/test');
const { loginThroughUi, startShiftIfRequired } = require('../support/auth');

function waitForApiResponse(page, pathFragment, expectedStatus) {
  return page.waitForResponse(
    (response) =>
      response.url().includes(pathFragment) && response.status() === expectedStatus,
    { timeout: 30_000 },
  );
}

test.describe('Authenticated route access', () => {
  test('loads Sales Kanban data after the required shift flow @staff @phase1', async ({ page }) => {
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

  test('loads Manager Dashboard data when manager credentials are configured @manager @phase3', async ({ page }) => {
    test.skip(
      !process.env.E2E_MANAGER_USER || !process.env.E2E_MANAGER_PASSWORD,
      'Set E2E_MANAGER_USER and E2E_MANAGER_PASSWORD to run the manager route smoke test.',
    );

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

  test('blocks staff access to the Manager Dashboard when opened directly @staff @phase1 @phase3', async ({ page }) => {
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

  test('blocks staff access to Purchase when opened directly @staff @phase1 @phase3', async ({ page }) => {
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