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
      node.focus();
      node.click();
    });
    await page
      .waitForFunction(
        () => document.querySelectorAll('flt-semantics').length > 0,
        { timeout: 10_000 },
      )
      .catch(() => {});
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

const CANVAS_LOGIN_TARGETS = {
  username: { xRatio: 0.140625, yRatio: 0.4583333333 },
  password: { xRatio: 0.140625, yRatio: 0.5416666667 },
  submit: { xRatio: 0.5, yRatio: 0.6305555556 },
};

const SHIFT_START_TARGET = { xRatio: 0.5, yRatio: 0.9555555556 };

async function clickCanvasTarget(page, target) {
  const viewport = page.viewportSize() || { width: 1280, height: 720 };
  const x = Math.round(viewport.width * target.xRatio);
  const y = Math.round(viewport.height * target.yRatio);

  await page.mouse.click(x, y);
}

async function setFocusedFlutterInputValue(page, value) {
  const editor = page.locator('flt-text-editing-host input.flt-text-editing').last();
  await editor.waitFor({ state: 'attached', timeout: 5_000 });
  await editor.evaluate((input, nextValue) => {
    input.focus();
    input.value = nextValue;
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
  }, value);
}

async function focusCanvasFieldAndSetValue(page, target, value) {
  for (let attempt = 0; attempt < 3; attempt += 1) {
    await clickCanvasTarget(page, target);
    await page.waitForTimeout(300);

    const hasEditor = await page
      .waitForFunction(
        () => document.querySelectorAll('flt-text-editing-host input.flt-text-editing').length > 0,
        { timeout: 1_500 },
      )
      .then(() => true)
      .catch(() => false);

    if (!hasEditor) {
      await page.waitForTimeout(500);
      continue;
    }

    await setFocusedFlutterInputValue(page, value);
    return;
  }

  throw new Error('Unable to focus Flutter canvas input');
}

async function hasAccessibleLoginFields(page) {
  const labeledUsername = page.getByRole('textbox', { name: /username/i }).first();
  const hasLabeledUsername = await labeledUsername
    .isVisible({ timeout: 1_500 })
    .catch(() => false);

  if (hasLabeledUsername) {
    return true;
  }

  const genericTextboxes = page.locator('input, textarea, [role="textbox"]');
  return (await genericTextboxes.count()) >= 2;
}

async function resolveTextbox(page, labelPattern, fallbackIndex) {
  const labeledTextbox = page.getByRole('textbox', { name: labelPattern }).first();
  const hasLabeledTextbox = await labeledTextbox.isVisible({ timeout: 3_000 }).catch(
    () => false,
  );

  if (hasLabeledTextbox) {
    return labeledTextbox;
  }

  const genericTextbox = page
    .locator('input, textarea, [role="textbox"]')
    .nth(fallbackIndex);
  await expect(genericTextbox).toBeVisible();
  return genericTextbox;
}

async function clickLoginAction(page) {
  const candidates = [
    page.getByRole('button', { name: /^login$/i }).first(),
    page.locator('button').filter({ hasText: /^login$/i }).first(),
    page.getByText(/^login$/i).last(),
  ];

  for (const locator of candidates) {
    const isVisible = await locator.isVisible({ timeout: 3_000 }).catch(() => false);
    if (!isVisible) {
      continue;
    }

    await locator.click({ force: true });
    return;
  }

  await page.keyboard.press('Enter');
}

async function loginThroughCanvas(page, user, password) {
  await focusCanvasFieldAndSetValue(page, CANVAS_LOGIN_TARGETS.username, user);

  await focusCanvasFieldAndSetValue(page, CANVAS_LOGIN_TARGETS.password, password);

  await page.waitForTimeout(300);
  await clickCanvasTarget(page, CANVAS_LOGIN_TARGETS.submit);
}

async function tryCanvasLogin(page, user, password) {
  for (let attempt = 0; attempt < 2; attempt += 1) {
    try {
      await loginThroughCanvas(page, user, password);
      return true;
    } catch {
      if (attempt === 1) {
        return false;
      }

      await page.goto('/pos/#/login');
      await waitForFlutterBoot(page);
      await page.waitForTimeout(4_000);
    }
  }

  return false;
}

async function loginThroughUi(page, options = {}) {
  const userEnv = options.userEnv || 'E2E_USER';
  const passwordEnv = options.passwordEnv || 'E2E_PASSWORD';
  const user = requireEnv(userEnv);
  const password = requireEnv(passwordEnv);

  await page.goto('/pos/#/login');
  await waitForFlutterBoot(page);
  await page.waitForTimeout(4_000);

  if (await tryCanvasLogin(page, user, password)) {
    await maybeChooseLoginMode(page);
  } else {
    await page.goto('/pos/#/login');
    await waitForFlutterBoot(page);
    await enableFlutterAccessibilityIfPresent(page);
    await page.waitForTimeout(1_000);

    if (!(await hasAccessibleLoginFields(page))) {
      throw new Error('Unable to access Flutter login fields through either canvas or semantics');
    }

    const usernameTextbox = await resolveTextbox(page, /username/i, 0);
    const passwordTextbox = await resolveTextbox(page, /password/i, 1);

    await usernameTextbox.fill(user);
    await passwordTextbox.fill(password);
    await clickLoginAction(page);
    await maybeChooseLoginMode(page);
  }

  await page.waitForURL((url) => !url.hash.endsWith('/login'), {
    timeout: 30_000,
  });

  await assertHasSessionCookie(page);
}

async function startShiftIfRequired(page) {
  if (!page.url().includes('/shift/start')) {
    return;
  }

  await page.waitForTimeout(1_000);
  await clickCanvasTarget(page, SHIFT_START_TARGET);
  await page.waitForURL((url) => !url.hash.endsWith('/shift/start'), {
    timeout: 30_000,
  });
}

module.exports = {
  assertHasSessionCookie,
  loginThroughUi,
  startShiftIfRequired,
};