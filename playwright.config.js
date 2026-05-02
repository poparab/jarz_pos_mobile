const { defineConfig, devices } = require('@playwright/test');
const { baseUrlFor } = require('./e2e/support/env');

module.exports = defineConfig({
  testDir: './e2e/specs',
  timeout: 60_000,
  workers: 1,
  expect: {
    timeout: 15_000,
  },
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: [
    ['list'],
    ['html', { open: 'never' }],
  ],
  use: {
    headless: true,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    locale: 'en-US',
    actionTimeout: 15_000,
    navigationTimeout: 30_000,
    ignoreHTTPSErrors: false,
    viewport: { width: 1440, height: 900 },
  },
  projects: [
    {
      name: 'staging-chromium',
      use: {
        ...devices['Desktop Chrome'],
        baseURL: baseUrlFor('staging'),
      },
    },
    {
      name: 'production-chromium',
      grepInvert: /@write/,
      use: {
        ...devices['Desktop Chrome'],
        baseURL: baseUrlFor('prod'),
      },
    },
  ],
});