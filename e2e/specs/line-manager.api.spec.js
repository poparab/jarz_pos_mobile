/**
 * Line-manager capability boundary — API level.
 *
 * WHY THIS FILE EXISTS
 * --------------------
 * `e2e/support/auth.js` has supported `E2E_LOGIN_MODE=line-manager` since it
 * was written, but no spec ever set it and there was no credential slot for a
 * line manager. So the tier that is allowed to CANCEL and RETURN real orders —
 * and is deliberately walled off from pricing, B2B and the Production Board —
 * had never been exercised by a single test.
 *
 * The expected boundary is derived from the client-side capability getters in
 * `lib/src/core/network/user_service.dart` and the role names in
 * `lib/src/core/constants/business_constants.dart` (`RoleNames`), and confirmed
 * against the backend gates:
 *
 *   ALLOWED  (UserRoles.canActAsLineManager / canAccessManagerDashboard /
 *             canAccessShiftMonitor -> backend ROLES.LINE_MANAGER_TIER)
 *     - jarz_pos.api.kanban.cancel_invoice
 *     - jarz_pos.api.returns.get_return_preview
 *     - jarz_pos.api.returns.submit_invoice_return
 *     - jarz_pos.api.manager.get_pos_shift_monitor
 *     - jarz_pos.api.manager.get_manager_dashboard_summary
 *     - jarz_pos.api.reports.get_materials_report  (ROLES.LINE_MANAGER_TIER)
 *
 *   DENIED
 *     - pricing WRITES   UserRoles.canEditPricing => isJarzManager only
 *                        (backend _ensure_full_manager_pricing_access needs
 *                        manager-pricing access AND B2B access)
 *     - B2B              UserRoles.canUseB2b; backend crm._can_access_b2b has
 *                        no line-manager entry
 *     - Production Board UserRoles.canAccessProductionBoard deliberately
 *                        EXCLUDES line managers (backend ROLES.PRODUCTION_VIEW)
 *     - jarz_pos.api.reports.get_final_products_report (JARZ Manager only)
 *
 * NOT every `jarz_pos.api.reports.*` endpoint is manager-only: `get_materials_report`
 * is gated on ROLES.LINE_MANAGER_TIER and so belongs in the ALLOWED list. Both
 * are asserted, so a future widening of either does not pass unnoticed.
 *
 * NETWORK ASSERTIONS ONLY. The Flutter web app renders to a canvas, so there is
 * nothing stable to click or read visually — every assertion here is on HTTP
 * status and refusal text.
 *
 * SAFETY: every probe uses deliberately non-existent document names, and the
 * pricing writes are sent as GET. Even if a gate regressed to fully open, no
 * document can be created, mutated or cancelled by this spec:
 *   - cancel_invoice / get_return_preview run their role check BEFORE loading
 *     the invoice, so a bogus id exercises the gate and then 404s internally;
 *   - submit_invoice_return returns "Select at least one line to return" for
 *     `lines=[]`, before touching any document;
 *   - the pricing writes throw "<x> not found" on the bogus arguments, and
 *     Frappe only commits on POST/PUT/DELETE.
 */

const { test, expect, request } = require('@playwright/test');
const { envValue, requireEnv } = require('../support/env');
const { requireCredentialTierForTest } = require('../support/credentials');

// Deliberately unresolvable. Named so anyone reading a staging Error Log knows
// instantly where the entry came from.
const PROBE_INVOICE = 'E2E-PERMISSION-PROBE-NO-SUCH-INVOICE';
const PROBE_PRICE_LIST = 'E2E-PERMISSION-PROBE-NO-SUCH-PRICE-LIST';
const PROBE_ITEM_GROUP = 'E2E-PERMISSION-PROBE-NO-SUCH-ITEM-GROUP';
const PROBE_ITEM = 'E2E-PERMISSION-PROBE-NO-SUCH-ITEM';
const PROBE_CUSTOMER = 'E2E-PERMISSION-PROBE-NO-SUCH-CUSTOMER';
const PROBE_REASON = 'E2E permission probe - must never reach a real document';

/**
 * The line-manager capability set.
 *
 * `refusalStatus` / `refusalPattern` describe what a REFUSAL looks like, so one
 * row drives both directions: the line manager must never see it, staff must
 * always see it.
 *
 * `allowedStatus: 200` means the probe is a harmless read that must succeed
 * outright. `allowedStatus: null` means the probe deliberately carries bogus
 * arguments, so the only honest assertion is "got past the permission gate".
 */
const LINE_MANAGER_CAPABILITIES = [
  {
    name: 'shift monitor',
    method: 'GET',
    path: '/api/method/jarz_pos.api.manager.get_pos_shift_monitor',
    refusalStatus: 403,
    refusalPattern: /Shift monitor access required/i,
    allowedStatus: 200,
  },
  {
    name: 'manager dashboard summary',
    method: 'GET',
    path: '/api/method/jarz_pos.api.manager.get_manager_dashboard_summary',
    refusalStatus: 403,
    refusalPattern: /Manager Dashboard access required/i,
    allowedStatus: 200,
  },
  {
    name: 'materials report',
    method: 'GET',
    path: '/api/method/jarz_pos.api.reports.get_materials_report',
    refusalStatus: 403,
    refusalPattern: /not permitted to access this report/i,
    allowedStatus: 200,
  },
  {
    name: 'cancel_invoice',
    method: 'POST',
    path: '/api/method/jarz_pos.api.kanban.cancel_invoice',
    form: { invoice_id: PROBE_INVOICE, reason: PROBE_REASON },
    // NOT a 403. `kanban.cancel_invoice` returns `_failure(...)` - an ordinary
    // dict - so its refusal arrives as HTTP 200 carrying
    // {"message":{"success":false,"error":"You are not permitted to cancel orders"}}.
    // Asserting 403 here would be asserting a bug that does not exist.
    refusalStatus: 200,
    refusalPattern: /You are not permitted to cancel orders/i,
    allowedStatus: null,
  },
  {
    name: 'get_return_preview',
    method: 'GET',
    path: '/api/method/jarz_pos.api.returns.get_return_preview',
    params: { invoice_id: PROBE_INVOICE },
    refusalStatus: 403,
    refusalPattern: /You are not permitted to return orders/i,
    allowedStatus: null,
  },
  {
    name: 'submit_invoice_return',
    method: 'POST',
    path: '/api/method/jarz_pos.api.returns.submit_invoice_return',
    form: { invoice_id: PROBE_INVOICE, reason: PROBE_REASON, lines: '[]' },
    refusalStatus: 403,
    refusalPattern: /You are not permitted to return orders/i,
    allowedStatus: null,
  },
];

/** Everything the line manager must be refused. */
const LINE_MANAGER_DENIED_ENDPOINTS = [
  {
    name: 'pricing write: set category price',
    method: 'GET',
    path: '/api/method/jarz_pos.api.price_lists.set_category_price',
    params: { price_list: PROBE_PRICE_LIST, item_group: PROBE_ITEM_GROUP, rate: 1 },
    status: 403,
    deniedPattern: /editing prices requires a full manager role/i,
  },
  {
    name: 'pricing write: set item override',
    method: 'GET',
    path: '/api/method/jarz_pos.api.price_lists.set_item_override',
    params: { price_list: PROBE_PRICE_LIST, item_code: PROBE_ITEM, rate: 1 },
    status: 403,
    deniedPattern: /editing prices requires a full manager role/i,
  },
  {
    name: 'pricing write: assign customer to price list',
    method: 'GET',
    path: '/api/method/jarz_pos.api.price_lists.assign_customer_to_price_list',
    params: { customer: PROBE_CUSTOMER, price_list: PROBE_PRICE_LIST },
    status: 403,
    deniedPattern: /editing prices requires a full manager role/i,
  },
  {
    name: 'B2B pipeline',
    method: 'GET',
    path: '/api/method/jarz_pos.api.crm.get_b2b_pipeline',
    // 417, not 403: `crm._ensure_b2b_access` calls `frappe.throw(msg)` with no
    // exception class, so Frappe raises ValidationError (http_status_code 417).
    // Recorded as-is rather than "corrected" to 403, because a test must
    // describe the server as it is, not as it ought to be.
    status: 417,
    deniedPattern: /B2B sales access required/i,
  },
  {
    name: 'production board: running work orders',
    method: 'GET',
    path: '/api/method/jarz_pos.api.manufacturing.list_running_work_orders',
    status: 403,
    deniedPattern: /production access required/i,
  },
  {
    name: 'reports: final products',
    method: 'GET',
    path: '/api/method/jarz_pos.api.reports.get_final_products_report',
    status: 403,
    deniedPattern: /Only JARZ Manager can access reports/i,
  },
];

// Role names, mirrored from lib/src/core/constants/business_constants.dart.
const ROLE_JARZ_LINE_MANAGER = 'JARZ line manager';
const ROLE_JARZ_MANAGER = 'JARZ Manager';
const ROLE_SYSTEM_MANAGER = 'System Manager';
const ROLE_ADMINISTRATOR = 'Administrator';
const ROLE_B2B_SALES_REP = 'B2B Sales Rep';
const PRODUCTION_ROLES = [
  'Manufacturing Manager',
  'Stock Manager',
  'Purchase Manager',
  'Production Operator',
];

async function createAuthenticatedContext(baseURL, userEnv, passwordEnv) {
  const apiContext = await request.newContext({
    baseURL,
    extraHTTPHeaders: { Accept: 'application/json' },
  });

  const loginResponse = await apiContext.post('/api/method/login', {
    form: { usr: requireEnv(userEnv), pwd: requireEnv(passwordEnv) },
  });

  expect(
    loginResponse.ok(),
    `login failed for ${userEnv} (status ${loginResponse.status()})`,
  ).toBeTruthy();
  return apiContext;
}

function withQuery(path, params) {
  if (!params) return path;
  const query = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value === undefined || value === null) continue;
    query.set(key, String(value));
  }
  const serialized = query.toString();
  return serialized ? `${path}?${serialized}` : path;
}

async function send(apiContext, endpoint) {
  if (endpoint.method === 'POST') {
    return apiContext.post(endpoint.path, { form: endpoint.form || {} });
  }
  return apiContext.get(withQuery(endpoint.path, endpoint.params));
}

async function fetchRoles(apiContext) {
  const response = await apiContext.get(
    '/api/method/jarz_pos.api.user.get_current_user_roles',
  );
  expect(
    response.status(),
    'get_current_user_roles must answer for an authenticated session',
  ).toBe(200);
  const payload = await response.json();
  const message = payload && payload.message ? payload.message : payload;
  return Array.isArray(message && message.roles) ? message.roles : [];
}

test.describe('Line manager capability boundary (API)', () => {
  test('the configured line-manager account really is only a line manager @line-manager @phase3', async ({}, testInfo) => {
    requireCredentialTierForTest('line-manager', testInfo);

    const apiContext = await createAuthenticatedContext(
      testInfo.project.use.baseURL,
      'E2E_LINE_MANAGER_USER',
      'E2E_LINE_MANAGER_PASSWORD',
    );

    try {
      const roles = await fetchRoles(apiContext);

      expect(
        roles,
        'E2E_LINE_MANAGER_USER must hold the "JARZ line manager" role, or every ' +
          'assertion in this file is about some other tier.',
      ).toContain(ROLE_JARZ_LINE_MANAGER);

      // A line manager that also holds a manager or production role would pass
      // the DENIED assertions for the wrong reason (or fail them for the wrong
      // reason). Fail early, naming the offending role.
      for (const forbiddenRole of [
        ROLE_JARZ_MANAGER,
        ROLE_SYSTEM_MANAGER,
        ROLE_ADMINISTRATOR,
        ROLE_B2B_SALES_REP,
        ...PRODUCTION_ROLES,
      ]) {
        expect(
          roles,
          `E2E_LINE_MANAGER_USER must NOT also hold "${forbiddenRole}" - that ` +
            'role grants capabilities this spec asserts the line manager lacks.',
        ).not.toContain(forbiddenRole);
      }
    } finally {
      await apiContext.dispose();
    }
  });

  // Tagged @write because it issues POSTs to mutating endpoints (cancel_invoice,
  // submit_invoice_return). The arguments cannot resolve to any document, so
  // nothing is actually written - but playwright.config.js keeps @write off the
  // production project, and a permission probe has no business POSTing to prod.
  test('line manager is ALLOWED the line-manager capability set @line-manager @write @phase3', async ({}, testInfo) => {
    requireCredentialTierForTest('line-manager', testInfo);

    const apiContext = await createAuthenticatedContext(
      testInfo.project.use.baseURL,
      'E2E_LINE_MANAGER_USER',
      'E2E_LINE_MANAGER_PASSWORD',
    );

    try {
      for (const capability of LINE_MANAGER_CAPABILITIES) {
        const response = await send(apiContext, capability);
        const body = await response.text();

        // A 403 on any of these is the regression that gated cancel/return on
        // the bare line-manager role for months.
        expect(
          response.status(),
          `${capability.name}: line manager must not be forbidden. Body: ${body}`,
        ).not.toBe(403);

        // The refusal TEXT must be absent even when the status is 200 -
        // cancel_invoice refuses inside a 200 envelope.
        expect(
          body,
          `${capability.name}: line manager received the refusal message`,
        ).not.toMatch(capability.refusalPattern);

        if (capability.allowedStatus !== null) {
          expect(
            response.status(),
            `${capability.name}: expected ${capability.allowedStatus}. Body: ${body}`,
          ).toBe(capability.allowedStatus);
          expect(body, capability.name).not.toHaveLength(0);
        }
      }
    } finally {
      await apiContext.dispose();
    }
  });

  test('line manager is DENIED pricing writes, B2B, the production board and manager reports @line-manager @phase3', async ({}, testInfo) => {
    requireCredentialTierForTest('line-manager', testInfo);

    const apiContext = await createAuthenticatedContext(
      testInfo.project.use.baseURL,
      'E2E_LINE_MANAGER_USER',
      'E2E_LINE_MANAGER_PASSWORD',
    );

    try {
      for (const endpoint of LINE_MANAGER_DENIED_ENDPOINTS) {
        const response = await send(apiContext, endpoint);
        const body = await response.text();

        // Status AND message: a refusal for the wrong reason (a 403 raised by a
        // missing argument, say) is a different bug wearing the same clothes.
        expect(
          response.status(),
          `${endpoint.name}: expected ${endpoint.status}. Body: ${body}`,
        ).toBe(endpoint.status);
        expect(body, `${endpoint.name}: wrong refusal message`).toMatch(
          endpoint.deniedPattern,
        );
      }
    } finally {
      await apiContext.dispose();
    }
  });

  // @write for the same reason as the ALLOWED test above: POSTs, no writes.
  test('staff is DENIED the entire line-manager capability set @staff @line-manager @write @phase3', async ({}, testInfo) => {
    requireCredentialTierForTest('staff', testInfo);

    expect(
      envValue('E2E_USER').trim().toLowerCase(),
      'E2E_USER must be a real staff account, distinct from E2E_LINE_MANAGER_USER',
    ).not.toBe(envValue('E2E_LINE_MANAGER_USER').trim().toLowerCase());

    const apiContext = await createAuthenticatedContext(
      testInfo.project.use.baseURL,
      'E2E_USER',
      'E2E_PASSWORD',
    );

    try {
      for (const capability of LINE_MANAGER_CAPABILITIES) {
        const response = await send(apiContext, capability);
        const body = await response.text();

        expect(
          response.status(),
          `${capability.name}: expected refusal status ${capability.refusalStatus}. Body: ${body}`,
        ).toBe(capability.refusalStatus);
        expect(
          body,
          `${capability.name}: staff was refused, but not for the expected reason`,
        ).toMatch(capability.refusalPattern);
      }
    } finally {
      await apiContext.dispose();
    }
  });
});
