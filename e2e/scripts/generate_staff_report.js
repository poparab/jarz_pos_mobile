const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..', '..');
const inputPath = path.join(repoRoot, 'test-results', 'staff-playwright-results.json');
const latestArtifactsDir = path.join(repoRoot, 'artifacts', 'e2e', 'staff', 'latest');
const createdDocsPath = path.join(latestArtifactsDir, 'created-docs.json');
const latestReportPath = path.join(latestArtifactsDir, 'report.md');
const documentationReportPath = path.join(
  repoRoot,
  'documentation',
  'JARZ_STAFF_STAGING_AUTOMATION_REPORT.md',
);

function loadJson(filePath, fallback) {
  if (!fs.existsSync(filePath)) {
    return fallback;
  }

  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function extractTags(text) {
  return Array.from(new Set(String(text || '').match(/@\w+/g) || []));
}

function summarizeResult(testCase) {
  const results = Array.isArray(testCase.results) ? testCase.results : [];
  const statuses = results.map((result) => result.status).filter(Boolean);

  if (statuses.some((status) => ['failed', 'timedOut'].includes(status))) {
    return 'failed';
  }
  if (statuses.some((status) => status === 'passed')) {
    return 'passed';
  }
  if (statuses.some((status) => status === 'skipped')) {
    return 'skipped';
  }
  return statuses[0] || 'unknown';
}

function firstError(testCase) {
  const results = Array.isArray(testCase.results) ? testCase.results : [];
  for (const result of results) {
    if (Array.isArray(result.errors) && result.errors.length > 0) {
      return result.errors[0].message || result.errors[0].value || 'Unknown error';
    }
    if (result.error) {
      return result.error.message || result.error.value || 'Unknown error';
    }
  }
  return '';
}

function flattenSuites(suite, fileHint = '') {
  const cases = [];
  const nextFileHint = suite.file || fileHint;

  for (const childSuite of suite.suites || []) {
    cases.push(...flattenSuites(childSuite, nextFileHint));
  }

  for (const spec of suite.specs || []) {
    for (const testCase of spec.tests || []) {
      const title = [spec.title, testCase.title].filter(Boolean).join(' :: ');
      cases.push({
        durationMs: (testCase.results || []).reduce(
          (total, result) => total + (result.duration || 0),
          0,
        ),
        error: firstError(testCase),
        file: spec.file || nextFileHint,
        phaseTags: extractTags(title).filter((tag) => /^@phase\d+$/.test(tag)),
        staffTagged: extractTags(title).includes('@staff'),
        status: summarizeResult(testCase),
        title,
      });
    }
  }

  return cases;
}

function buildPhaseBuckets(testCases) {
  const buckets = new Map();

  for (const testCase of testCases) {
    const phases = testCase.phaseTags.length > 0 ? testCase.phaseTags : ['@phase-unknown'];
    for (const phase of phases) {
      if (!buckets.has(phase)) {
        buckets.set(phase, []);
      }
      buckets.get(phase).push(testCase);
    }
  }

  return Array.from(buckets.entries()).sort(([left], [right]) => left.localeCompare(right));
}

function statusEmoji(status) {
  switch (status) {
    case 'passed':
      return 'PASS';
    case 'failed':
      return 'FAIL';
    case 'skipped':
      return 'SKIP';
    default:
      return status.toUpperCase();
  }
}

function escapeTable(text) {
  return String(text || '')
    .replace(/\u001b\[[0-9;]*m/g, '')
    .replace(/\|/g, '\\|')
    .replace(/\n+/g, ' ')
    .trim();
}

function buildMarkdown(testCases, createdDocs) {
  const summary = {
    failed: testCases.filter((testCase) => testCase.status === 'failed').length,
    passed: testCases.filter((testCase) => testCase.status === 'passed').length,
    skipped: testCases.filter((testCase) => testCase.status === 'skipped').length,
  };

  const lines = [
    '# Jarz Staff Staging Automation Report',
    '',
    `- Generated: ${new Date().toISOString()}`,
    '- Environment: staging',
    '- Scope: staff-tagged Playwright staff automation suite',
    `- Summary: ${summary.passed} passed, ${summary.failed} failed, ${summary.skipped} skipped`,
    '',
  ];

  if (createdDocs && Object.values(createdDocs).some((entries) => Array.isArray(entries) && entries.length > 0)) {
    lines.push('## Created Docs');
    lines.push('');
    for (const [bucketName, entries] of Object.entries(createdDocs)) {
      if (!Array.isArray(entries) || entries.length === 0) {
        continue;
      }
      lines.push(`- ${bucketName}: ${entries.join(', ')}`);
    }
    lines.push('');
  }

  for (const [phase, phaseCases] of buildPhaseBuckets(testCases)) {
    lines.push(`## ${phase.replace('@', '').toUpperCase()}`);
    lines.push('');
    lines.push('| Scenario | Status | Duration (ms) | Notes |');
    lines.push('|---|---|---:|---|');
    for (const testCase of phaseCases) {
      lines.push(
        `| ${escapeTable(testCase.title)} | ${statusEmoji(testCase.status)} | ${testCase.durationMs} | ${escapeTable(testCase.error)} |`,
      );
    }
    lines.push('');
  }

  return `${lines.join('\n')}\n`;
}

if (!fs.existsSync(inputPath)) {
  throw new Error(`Playwright JSON report not found: ${inputPath}`);
}

const reportJson = loadJson(inputPath, {});
const createdDocs = loadJson(createdDocsPath, {});
const suites = Array.isArray(reportJson.suites) ? reportJson.suites : [];
const allCases = suites.flatMap((suite) => flattenSuites(suite));
const staffCases = allCases.filter((testCase) => testCase.staffTagged);
const markdown = buildMarkdown(staffCases, createdDocs);

fs.mkdirSync(latestArtifactsDir, { recursive: true });
fs.writeFileSync(latestReportPath, markdown);
fs.writeFileSync(documentationReportPath, markdown);

console.log(`Staff report written to ${documentationReportPath}`);