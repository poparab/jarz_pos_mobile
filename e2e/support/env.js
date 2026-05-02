const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

const repoRoot = path.resolve(__dirname, '..', '..');

for (const fileName of ['.env.e2e.local', '.env.e2e']) {
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

function requireEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(
      `Missing required environment variable ${name}. ` +
        'Copy .env.e2e.example to .env.e2e.local and fill in credentials before running browser E2E tests.',
    );
  }
  return value;
}

function optionalEnv(name, fallback = '') {
  return process.env[name] || fallback;
}

module.exports = {
  baseUrlFor,
  normalizeEnvironmentName,
  optionalEnv,
  repoRoot,
  requireEnv,
};