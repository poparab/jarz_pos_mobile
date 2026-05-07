const { test, expect } = require('@playwright/test');
const { assertHasSessionCookie, loginThroughUi } = require('../support/auth');

test.describe('Browser auth smoke', () => {
  test('logs in through the real web UI and establishes a session @staff @phase1', async ({ page }) => {
    await loginThroughUi(page);

    await assertHasSessionCookie(page);
    await expect(page).toHaveURL(/\/pos\/#\/(?!login)/);
    await expect(page.getByText(/connection failed/i)).toHaveCount(0);
  });
});