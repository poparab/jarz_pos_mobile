const { test, expect } = require('@playwright/test');
const { assertHasSessionCookie, loginThroughUi } = require('../support/auth');
const { requireCredentialTier } = require('../support/credentials');

test.describe('Browser auth smoke', () => {
  // E2E_USER no longer falls back to STAGING_USER. Without an explicit staff
  // credential this group skips LOUDLY rather than logging in as the owner and
  // calling that a staff smoke test.
  requireCredentialTier('staff');

  test('logs in through the real web UI and establishes a session @staff @phase1', async ({ page }) => {
    await loginThroughUi(page);

    await assertHasSessionCookie(page);
    await expect(page).toHaveURL(/\/pos\/#\/(?!login)/);
    await expect(page.getByText(/connection failed/i)).toHaveCount(0);
  });
});
