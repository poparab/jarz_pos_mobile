# Jarz Staff Staging Automation Report

- Generated: 2026-05-07T14:11:48.960Z
- Environment: staging
- Scope: staff-tagged Playwright staff automation suite
- Summary: 15 passed, 1 failed, 1 skipped

## Created Docs

- contacts: E2E Staff 20260507140927-E2E Staff 20260507140927-1
- customers: E2E Staff 20260507140927
- paymentEntries: ACC-PAY-2026-014985
- salesInvoices: ACC-SINV-2026-15787, ACC-SINV-2026-15788, ACC-SINV-2026-15789

## PHASE1

| Scenario | Status | Duration (ms) | Notes |
|---|---|---:|---|
| logs in through the real web UI and establishes a session @staff @phase1 | PASS | 9281 |  |
| loads Sales Kanban data after the required shift flow @staff @phase1 | PASS | 10737 |  |
| blocks staff access to the Manager Dashboard when opened directly @staff @phase1 @phase3 | PASS | 9146 |  |
| blocks staff access to Purchase when opened directly @staff @phase1 @phase3 | PASS | 9407 |  |
| phase 1: staff can resolve an assigned POS profile and load catalog @staff @write @phase1 | PASS | 96 |  |
| phase 1: staff can start a shift and load its summary @staff @write @phase1 | PASS | 294 |  |
| phase 1: staff can create and search a customer with backend records @staff @write @phase1 | PASS | 845 |  |
| phase 1: staff can create a cash invoice with a payment entry @staff @write @phase1 | PASS | 2486 |  |
| phase 1: staff can create a settle-later invoice without a payment entry @staff @write @phase1 | PASS | 1224 |  |
| phase 1 and 3: staff expense stays pending and approval is blocked @staff @write @phase1 @phase3 | PASS | 421 |  |

## PHASE2

| Scenario | Status | Duration (ms) | Notes |
|---|---|---:|---|
| phase 2: staff can pay an invoice by Instapay and upload a receipt @staff @write @phase2 | FAIL | 1506 | Error: expect(received).toBeTruthy() Received: false    at ..\support\api.js:395   393 \|     receiptForm,   394 \|   ); > 395 \|   expect(response.ok()).toBeTruthy();       \|                         ^   396 \|   expect(message.receipt_name).toBeTruthy();   397 \|   return message;   398 \| }     at createPaymentReceipt (C:\ERPNext\jarz_pos_mobile\jarz_pos\e2e\support\api.js:395:25)     at C:\ERPNext\jarz_pos_mobile\jarz_pos\e2e\specs\staff-workflows.api.spec.js:409:21 |
| phase 2: manager can confirm the uploaded Instapay receipt @staff @write @phase2 | SKIP | 1 |  |
| phase 2: staff can pay an invoice by Mobile Wallet @staff @write @phase2 | PASS | 1876 |  |
| phase 2: staff can assign a delivery slot to an invoice @staff @write @phase2 | PASS | 1332 |  |
| phase 2: staff can create a pickup invoice path @staff @write @phase2 | PASS | 1246 |  |
| phase 2: staff can open courier balances without a permission error @staff @write @phase2 | PASS | 66 |  |

## PHASE3

| Scenario | Status | Duration (ms) | Notes |
|---|---|---:|---|
| staff is denied manager-only endpoints @staff @phase3 | PASS | 679 |  |
| blocks staff access to the Manager Dashboard when opened directly @staff @phase1 @phase3 | PASS | 9146 |  |
| blocks staff access to Purchase when opened directly @staff @phase1 @phase3 | PASS | 9407 |  |
| phase 1 and 3: staff expense stays pending and approval is blocked @staff @write @phase1 @phase3 | PASS | 421 |  |

