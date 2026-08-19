const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

const repoRoot = path.resolve(__dirname, '..', '..');

// Aliases exist so a single owner credential can drive the tier it genuinely
// belongs to — the MANAGER tier — without a second .env entry.
//
// E2E_USER / E2E_PASSWORD used to alias to STAGING_USER / STAGING_PASSWORD.
// That made "staff" and "manager" literally the same owner account, so
// "staff is denied manager-only endpoints" was really asserting that the OWNER
// is denied them: it received 200s and failed for the wrong reason, while the
// manager spec skipped. A staff credential must now be supplied explicitly or
// the staff specs skip loudly.
//
// E2E_LINE_MANAGER_* has NO alias for the same reason: a JARZ line manager is a
// distinct capability tier (may cancel/return, may NOT edit pricing, reach B2B,
// or open the Production Board). Aliasing it to anything would silently retire
// the only test that proves that boundary.
const envAliases = {
  E2E_MANAGER_PASSWORD: 'STAGING_PASSWORD',
  E2E_MANAGER_USER: 'STAGING_USER',
  E2E_POS_PROFILE: 'STAGING_POS_PROFILE',
};

for (const fileName of ['.env.e2e.local', '.env.e2e', '.env.test.local']) {
  const fullPath = path.join(repoRoot, fileName);
  if (fs.existsSync(fullPath)) {
    dotenv.config({ path: fullPath, override: false });
  }
}

const defaultBaseUrls = {
  staging: 'https://erpstg.orderjarz.com',
  prod: 'https://erp.orderjarz.com',
};

/**
 * The three credential tiers the E2E suite distinguishes.
 *
 * `roleHint` documents what the account must actually hold on the server for
 * the specs gated on that tier to mean anything. Mirrors
 * `lib/src/core/constants/business_constants.dart` (`RoleNames`) and the
 * backend `jarz_pos.constants.ROLES`.
 */
const CREDENTIAL_TIERS = {
  staff: {
    key: 'staff',
    label: 'staff',
    userEnv: 'E2E_USER',
    passwordEnv: 'E2E_PASSWORD',
    roleHint:
      'A "Jarz POS Staff" account with NO manager role. Must NOT be the owner/manager account.',
  },
  manager: {
    key: 'manager',
    label: 'manager',
    userEnv: 'E2E_MANAGER_USER',
    passwordEnv: 'E2E_MANAGER_PASSWORD',
    roleHint: 'A "JARZ Manager" (or Administrator) account.',
  },
  'line-manager': {
    key: 'line-manager',
    label: 'line manager',
    userEnv: 'E2E_LINE_MANAGER_USER',
    passwordEnv: 'E2E_LINE_MANAGER_PASSWORD',
    roleHint:
      'A "JARZ line manager" account that is NOT also a JARZ Manager / System Manager / B2B Sales Rep.',
  },
};

function normalizeEnvironmentName(name) {
  const raw = (name || '').trim().toLowerCase();
  if (raw === 'production') {
    return 'prod';
  }
  if (raw === 'staging' || raw === 'prod') {
    return raw;
  }
  return 'staging';
}

function trimTrailingSlash(value) {
  return value.replace(/\/+$/, '');
}

function baseUrlFor(environmentName) {
  if (process.env.E2E_BASE_URL) {
    return trimTrailingSlash(process.env.E2E_BASE_URL);
  }
  const normalized = normalizeEnvironmentName(environmentName);
  return defaultBaseUrls[normalized];
}

function envValue(name) {
  const directValue = process.env[name];
  if (directValue) {
    return directValue;
  }

  const alias = envAliases[name];
  if (!alias) {
    return '';
  }

  return process.env[alias] || '';
}

function requireEnv(name) {
  const value = envValue(name);
  if (!value) {
    throw new Error(
      `Missing required environment variable ${name}. ` +
        'Copy .env.e2e.example to .env.e2e.local and fill in all three credential ' +
        'tiers (staff, manager, line manager) before running E2E tests.',
    );
  }
  return value;
}

function optionalEnv(name, fallback = '') {
  return envValue(name) || fallback;
}

function credentialTier(tierName) {
  const tier = CREDENTIAL_TIERS[tierName];
  if (!tier) {
    throw new Error(
      `Unknown credential tier "${tierName}". Known tiers: ${Object.keys(
        CREDENTIAL_TIERS,
      ).join(', ')}.`,
    );
  }
  return tier;
}

/** Env var names for [tierName] that resolve to nothing. */
function missingCredentials(tierName) {
  const tier = credentialTier(tierName);
  return [tier.userEnv, tier.passwordEnv].filter((name) => !envValue(name));
}

function hasCredentials(tierName) {
  return missingCredentials(tierName).length === 0;
}

module.exports = {
  CREDENTIAL_TIERS,
  baseUrlFor,
  credentialTier,
  envValue,
  hasCredentials,
  missingCredentials,
  normalizeEnvironmentName,
  optionalEnv,
  repoRoot,
  requireEnv,
};
