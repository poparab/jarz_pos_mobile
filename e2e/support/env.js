const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

const repoRoot = path.resolve(__dirname, '..', '..');

const envAliases = {
  E2E_MANAGER_PASSWORD: 'STAGING_PASSWORD',
  E2E_MANAGER_USER: 'STAGING_USER',
  E2E_PASSWORD: 'STAGING_PASSWORD',
  E2E_POS_PROFILE: 'STAGING_POS_PROFILE',
  E2E_USER: 'STAGING_USER',
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
        'Copy .env.e2e.example to .env.e2e.local or provide the matching STAGING_* aliases before running browser E2E tests.',
    );
  }
  return value;
}

function optionalEnv(name, fallback = '') {
  return envValue(name) || fallback;
}

module.exports = {
  baseUrlFor,
  normalizeEnvironmentName,
  optionalEnv,
  repoRoot,
  requireEnv,
};