const { test, expect } = require('@playwright/test');
const { loginThroughUi } = require('../support/auth');

test.describe('Authenticated read-only navigation', () => {
  test('opens the Sales Kanban route after UI login', async ({ page }) => {
    await loginThroughUi(page);

    await page.goto('/pos/#/kanban');
    await expect(page).toHaveURL(/\/pos\/#\/kanban/);
    await expect(page.getByText(/sales kanban|kanban/i).first()).toBeVisible();
  });

  test('opens the Manager Dashboard when manager credentials are configured', async ({ page }) => {
    test.skip(
      !process.env.E2E_MANAGER_USER || !process.env.E2E_MANAGER_PASSWORD,
      'Set E2E_MANAGER_USER and E2E_MANAGER_PASSWORD to run the manager route smoke test.',
    );

    await loginThroughUi(page, {
      userEnv: 'E2E_MANAGER_USER',
      passwordEnv: 'E2E_MANAGER_PASSWORD',
    });

    await page.goto('/pos/#/manager');
    await expect(page).toHaveURL(/\/pos\/#\/manager/);
    await expect(page.getByText(/manager dashboard/i).first()).toBeVisible();
  });
});