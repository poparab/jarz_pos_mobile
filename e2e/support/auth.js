const { expect } = require('@playwright/test');
const { optionalEnv, requireEnv } = require('./env');

async function waitForFlutterBoot(page) {
  await page
    .waitForFunction(
      () =>
        !!document.querySelector('flt-semantics-placeholder') ||
        !!document.querySelector('flt-glass-pane') ||
        !!document.querySelector('canvas'),
      { timeout: 30_000 },
    )
    .catch(() => {});
}

async function enableFlutterAccessibilityIfPresent(page) {
  const semanticsPlaceholder = page.locator(
    'flt-semantics-placeholder[aria-label="Enable accessibility"]',
  );

  if ((await semanticsPlaceholder.count()) > 0) {
    await semanticsPlaceholder.evaluate((node) => {
      node.dispatchEvent(
        new MouseEvent('click', {
          bubbles: true,
          cancelable: true,
          view: window,
        }),
      );
    });
    return;
  }

  const enableButton = page.getByRole('button', { name: /enable accessibility/i });
  const hasAccessibilityGate = await enableButton.isVisible({ timeout: 5_000 }).catch(
    () => false,
  );

  if (hasAccessibilityGate) {
    await enableButton.click({ force: true });
  }
}

async function maybeChooseLoginMode(page) {
  const configuredMode = optionalEnv('E2E_LOGIN_MODE').trim().toLowerCase();
  if (!configuredMode) {
    return;
  }

  const dialog = page.getByRole('dialog');
  const hasDialog = await dialog.isVisible({ timeout: 5_000 }).catch(() => false);
  if (!hasDialog) {
    return;
  }

  const target = configuredMode === 'line-manager' ? /line manager/i : /employee/i;
  await dialog.getByText(target).click();
}

async function assertHasSessionCookie(page) {
  await expect
    .poll(async () => {
      const cookies = await page.context().cookies();
      return cookies.some((cookie) => cookie.name === 'sid');
    })
    .toBeTruthy();
}

async function loginThroughUi(page, options = {}) {
  const userEnv = options.userEnv || 'E2E_USER';
  const passwordEnv = options.passwordEnv || 'E2E_PASSWORD';

  await page.goto('/pos/#/login');
  await waitForFlutterBoot(page);
  await enableFlutterAccessibilityIfPresent(page);
  await page.waitForTimeout(1_000);
  await expect(page.getByRole('textbox', { name: /username/i })).toBeVisible();

  await page.getByRole('textbox', { name: /username/i }).fill(requireEnv(userEnv));
  await page.getByRole('textbox', { name: /password/i }).fill(requireEnv(passwordEnv));
  await page.getByRole('button', { name: /^login$/i }).click();

  await maybeChooseLoginMode(page);

  await page.waitForURL((url) => !url.hash.endsWith('/login'), {
    timeout: 30_000,
  });

  await assertHasSessionCookie(page);
}

module.exports = {
  assertHasSessionCookie,
  loginThroughUi,
};