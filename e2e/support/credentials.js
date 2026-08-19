const { test } = require('@playwright/test');
const {
  credentialTier,
  hasCredentials,
  missingCredentials,
} = require('./env');

/**
 * Credential gating for the E2E specs.
 *
 * A spec that needs a credential it does not have must SKIP LOUDLY. It must
 * never (a) silently pass, nor (b) quietly fall back to a different account —
 * the E2E_USER -> STAGING_USER alias did exactly (b), which is how the "staff
 * is denied manager-only endpoints" spec ended up running as the owner.
 *
 * Set E2E_STRICT_CREDENTIALS=1 (recommended in CI) to turn every such skip
 * into a hard failure, so a permission suite can never go green on an empty
 * .env.
 */

const STRICT = /^(1|true|yes)$/i.test(String(process.env.E2E_STRICT_CREDENTIALS || ''));

const announced = new Set();

function describeGap(tierName) {
  const tier = credentialTier(tierName);
  const missing = missingCredentials(tierName);
  return (
    `MISSING ${tier.label.toUpperCase()} CREDENTIALS: ${missing.join(', ')} ` +
    `is not set. ${tier.roleHint} ` +
    'Add it to .env.e2e.local (see .env.e2e.example). ' +
    'Until then these assertions prove nothing.'
  );
}

function announce(tierName, message) {
  const key = `${tierName}:${message}`;
  if (announced.has(key)) {
    return;
  }
  announced.add(key);
  // Deliberately console.error, not console.log: this has to be visible in a
  // scrolled CI log, next to the failures it is standing in for.
  console.error(
    `\n${'='.repeat(78)}\n[e2e] ${message}\n${'='.repeat(78)}\n`,
  );
}

/**
 * Call in a `test.describe` body. Skips (or, under strict mode, fails) every
 * test in the group when [tierName]'s credentials are absent.
 */
function requireCredentialTier(tierName) {
  if (hasCredentials(tierName)) {
    return;
  }

  const message = describeGap(tierName);
  announce(tierName, message);

  if (STRICT) {
    test('credentials are configured', () => {
      throw new Error(`${message} (E2E_STRICT_CREDENTIALS=1)`);
    });
  }

  test.skip(true, message);
}

/**
 * Call inside a single test body when only that test needs [tierName].
 * Requires `testInfo` so the reason is attached to the report entry rather than
 * living only in stdout.
 */
function requireCredentialTierForTest(tierName, testInfo) {
  if (hasCredentials(tierName)) {
    return;
  }

  const message = describeGap(tierName);
  announce(tierName, message);

  if (testInfo) {
    testInfo.annotations.push({
      type: 'missing-credentials',
      description: message,
    });
  }

  if (STRICT) {
    throw new Error(`${message} (E2E_STRICT_CREDENTIALS=1)`);
  }

  test.skip(true, message);
}

module.exports = {
  STRICT,
  describeGap,
  requireCredentialTier,
  requireCredentialTierForTest,
};
