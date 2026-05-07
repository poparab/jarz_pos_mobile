const fs = require('fs');
const path = require('path');
const { test, expect } = require('@playwright/test');
const {
  approveExpense,
  buildInvoiceForm,
  buildSingleItemCart,
  buildStaffCustomerInput,
  confirmReceipt,
  createAuthenticatedContext,
  createCustomer,
  createExpense,
  createPaymentReceipt,
  createPosInvoice,
  endShift,
  findLinkedPaymentEntry,
  getActiveShift,
  getCourierBalances,
  getCustomerShippingAddresses,
  getExpenseBootstrap,
  getNextAvailableSlot,
  getPosProfiles,
  getProfileProducts,
  getResource,
  getShiftPaymentMethods,
  getShiftSummary,
  getTerritories,
  listResources,
  numericValue,
  optionalEnv,
  payInvoice,
  pickSellableItem,
  postForm,
  searchCustomers,
  slotDurationSeconds,
  startShift,
  timestampTag,
  tinyPngBase64,
  updateInvoiceDeliverySlot,
  uploadReceiptImage,
} = require('../support/api');
const { repoRoot } = require('../support/env');

const latestArtifactsDir = path.join(repoRoot, 'artifacts', 'e2e', 'staff', 'latest');
const createdDocsPath = path.join(latestArtifactsDir, 'created-docs.json');

test.describe('Staff workflow API phases @staff', () => {
  let staffApi;
  let managerApi;
  let verificationApi;
  let posProfile;
  let profileNames = [];
  let catalogItem;
  let territory;
  let seededCustomer;
  let seededAddressBook;
  let uploadedReceiptName = null;
  let suiteShift = {
    modeOfPayment: 'Cash',
    openedBySuite: false,
    openingEntry: null,
  };

  const createdDocs = {
    contacts: [],
    customers: [],
    expenseRequests: [],
    paymentEntries: [],
    paymentReceipts: [],
    posClosingEntries: [],
    posOpeningEntries: [],
    salesInvoices: [],
  };

  function persistCreatedDocs() {
    fs.mkdirSync(latestArtifactsDir, { recursive: true });
    fs.writeFileSync(createdDocsPath, JSON.stringify(createdDocs, null, 2));
  }

  async function ensureManagerContext(baseURL) {
    if (!process.env.E2E_MANAGER_USER || !process.env.E2E_MANAGER_PASSWORD) {
      return null;
    }

    return createAuthenticatedContext(
      baseURL,
      'E2E_MANAGER_USER',
      'E2E_MANAGER_PASSWORD',
    );
  }

  async function resolveUsablePosProfile() {
    const configuredProfile = optionalEnv('E2E_POS_PROFILE').trim();
    if (configuredProfile) {
      expect(profileNames).toContain(configuredProfile);
      return configuredProfile;
    }

    for (const profileName of profileNames) {
      const activeShift = await getActiveShift(staffApi, profileName);
      if (!activeShift || Number(activeShift.is_current_user || 0) === 1) {
        return profileName;
      }
    }

    return profileNames[0];
  }

  async function ensureSeededCustomer() {
    if (seededCustomer) {
      return seededCustomer;
    }

    const territoryId = territory.name || territory.id;
    const customerInput = buildStaffCustomerInput(territoryId);
    const createdCustomer = await createCustomer(staffApi, customerInput);
    const matches = await searchCustomers(staffApi, createdCustomer.customer_name);
    const matchedCustomer = matches.find(
      (customer) =>
        String(customer.name || '') === String(createdCustomer.name || '') ||
        String(customer.customer_name || '') ===
          String(createdCustomer.customer_name || ''),
    );

    expect(matchedCustomer).toBeTruthy();
    seededCustomer = createdCustomer;
    createdDocs.customers.push(createdCustomer.name);
    if (createdCustomer.customer_primary_contact) {
      createdDocs.contacts.push(createdCustomer.customer_primary_contact);
      createdDocs.contacts = createdDocs.contacts.filter(Boolean);
    }
    persistCreatedDocs();
    return seededCustomer;
  }

  async function ensureSeededAddressBook() {
    if (seededAddressBook) {
      return seededAddressBook;
    }

    const customer = await ensureSeededCustomer();
    seededAddressBook = await getCustomerShippingAddresses(staffApi, customer.name);
    return seededAddressBook;
  }

  async function ensureManagedShift() {
    if (suiteShift.openingEntry) {
      return suiteShift;
    }

    const activeShift = await getActiveShift(staffApi, posProfile);
    if (activeShift && Number(activeShift.is_current_user || 0) === 1) {
      suiteShift = {
        modeOfPayment: 'Cash',
        openedBySuite: false,
        openingEntry: String(activeShift.name || activeShift.opening_entry || ''),
      };
      return suiteShift;
    }

    const paymentMethods = await getShiftPaymentMethods(staffApi, posProfile);
    expect(paymentMethods.length).toBeGreaterThan(0);

    const primaryMethod = paymentMethods[0];
    const openingAmount = numericValue(
      primaryMethod.suggested_opening_amount ??
        primaryMethod.default_amount ??
        primaryMethod.current_balance,
    );

    const startedShift = await startShift(staffApi, posProfile, [
      {
        mode_of_payment: primaryMethod.mode_of_payment,
        opening_amount: openingAmount,
      },
    ]);

    suiteShift = {
      modeOfPayment: String(primaryMethod.mode_of_payment || 'Cash'),
      openedBySuite: true,
      openingEntry: startedShift.opening_entry,
    };
    createdDocs.posOpeningEntries.push(startedShift.opening_entry);
    persistCreatedDocs();
    return suiteShift;
  }

  async function createTrackedInvoice(overrides = {}) {
    const customer = await ensureSeededCustomer();
    const addressBook = await ensureSeededAddressBook();
    const shippingAddressName =
      addressBook.selected_address_name || customer.customer_primary_address;

    const invoice = await createPosInvoice(
      staffApi,
      buildInvoiceForm({
        cartItems: buildSingleItemCart(catalogItem),
        customerName: customer.name,
        posProfile,
        shippingAddressName,
        ...overrides,
      }),
    );

    createdDocs.salesInvoices.push(invoice.invoice_name);
    persistCreatedDocs();
    return invoice;
  }

  test.beforeAll(async ({}, testInfo) => {
    staffApi = await createAuthenticatedContext(testInfo.project.use.baseURL);
    managerApi = await ensureManagerContext(testInfo.project.use.baseURL);
    verificationApi = managerApi || staffApi;

    const profiles = await getPosProfiles(staffApi);
    profileNames = profiles.map((profile) => profile.name);
    expect(profileNames.length).toBeGreaterThan(0);

    posProfile = await resolveUsablePosProfile();

    const territories = await getTerritories(staffApi);
    territory =
      territories.find((candidate) => Number(candidate.is_group || 0) === 0) ||
      territories[0];
    expect(territory).toBeTruthy();

    const items = await getProfileProducts(staffApi, posProfile);
    catalogItem = pickSellableItem(items);
    expect(catalogItem).toBeTruthy();

    persistCreatedDocs();
  });

  test.afterAll(async () => {
    if (suiteShift.openedBySuite && suiteShift.openingEntry) {
      try {
        const summary = await getShiftSummary(staffApi, suiteShift.openingEntry);
        const paymentRow = Array.isArray(summary.payment_reconciliation)
          ? summary.payment_reconciliation[0]
          : null;
        const closingAmount = numericValue(
          paymentRow?.expected_amount ?? summary.account_balance,
        );
        const closingResult = await endShift(staffApi, suiteShift.openingEntry, [
          {
            closing_amount: closingAmount,
            mode_of_payment: paymentRow?.mode_of_payment || suiteShift.modeOfPayment,
          },
        ]);
        createdDocs.posClosingEntries.push(closingResult.closing_entry);
        persistCreatedDocs();
      } catch {
        // Best effort cleanup for staging-only automation data.
      }
    }

    await staffApi?.dispose();
    await managerApi?.dispose();
  });

  test('phase 1: staff can resolve an assigned POS profile and load catalog @staff @write @phase1', async () => {
    expect(profileNames).toContain(posProfile);

    const items = await getProfileProducts(staffApi, posProfile);
    expect(items.length).toBeGreaterThan(0);
    expect(String(catalogItem.item_name || catalogItem.name || '')).not.toHaveLength(0);
  });

  test('phase 1: staff can start a shift and load its summary @staff @write @phase1', async () => {
    const shift = await ensureManagedShift();
    const activeShift = await getActiveShift(staffApi, posProfile);
    const summary = await getShiftSummary(staffApi, shift.openingEntry);

    expect(String(activeShift.name || activeShift.opening_entry || '')).toBe(
      shift.openingEntry,
    );
    expect(Array.isArray(summary.payment_reconciliation)).toBeTruthy();
    expect(numericValue(summary.account_balance)).toBeGreaterThanOrEqual(0);
  });

  test('phase 1: staff can create and search a customer with backend records @staff @write @phase1', async () => {
    const customer = await ensureSeededCustomer();
    const addressBook = await ensureSeededAddressBook();
    const customerDoc = await getResource(verificationApi, 'Customer', customer.name);
    const addressDoc = await getResource(
      verificationApi,
      'Address',
      customer.customer_primary_address,
    );
    const contactDoc = await getResource(
      verificationApi,
      'Contact',
      customer.customer_primary_contact,
    );

    expect(customerDoc.customer_name).toBe(customer.customer_name);
    expect(customerDoc.territory).toBe(customer.territory);
    expect(addressDoc.address_line1).toContain('E2E Address');
    expect(String(contactDoc.name || '')).toBe(customer.customer_primary_contact);
    expect(String(addressBook.default_phone || customerDoc.mobile_no || '')).toContain(
      customer.mobile_no,
    );
    expect(Array.isArray(addressBook.addresses)).toBeTruthy();
    expect(addressBook.addresses.length).toBeGreaterThan(0);
    expect(addressBook.selected_address_name).toBe(customer.customer_primary_address);
  });

  test('phase 1: staff can create a cash invoice with a payment entry @staff @write @phase1', async () => {
    await ensureManagedShift();
    const invoice = await createTrackedInvoice();
    const payment = await payInvoice(staffApi, {
      invoice_name: invoice.invoice_name,
      payment_mode: 'cash',
      pos_profile: posProfile,
    });
    const salesInvoice = await getResource(
      verificationApi,
      'Sales Invoice',
      invoice.invoice_name,
    );
    const paymentEntry = await getResource(
      verificationApi,
      'Payment Entry',
      payment.payment_entry,
    );

    expect(numericValue(salesInvoice.outstanding_amount)).toBeCloseTo(0, 2);
    expect(Number(salesInvoice.docstatus)).toBe(1);
    expect(paymentEntry).toBeTruthy();
    expect(String(paymentEntry.paid_to || '')).toContain(posProfile);
    expect(String(payment.name || payment.payment_entry || '')).toBe(String(paymentEntry.name));

    createdDocs.paymentEntries.push(paymentEntry.name);
    persistCreatedDocs();
  });

  test('phase 1: staff can create a settle-later invoice without a payment entry @staff @write @phase1', async () => {
    await ensureManagedShift();
    const invoice = await createTrackedInvoice();
    const salesInvoice = await getResource(
      verificationApi,
      'Sales Invoice',
      invoice.invoice_name,
    );

    expect(Number(salesInvoice.docstatus)).toBe(1);
    expect(numericValue(salesInvoice.outstanding_amount)).toBeGreaterThan(0);
    expect(String(salesInvoice.status || '').toLowerCase()).not.toBe('paid');
  });

  test('phase 1 and 3: staff expense stays pending and approval is blocked @staff @write @phase1 @phase3', async () => {
    const bootstrap = await getExpenseBootstrap(staffApi);
    const reason = (bootstrap.reasons || [])[0];
    const paymentSource = (bootstrap.payment_sources || []).find(
      (source) =>
        String(source.pos_profile || source.label || '').trim() === posProfile ||
        String(source.category || '').trim().toLowerCase() === 'pos_profile',
    );

    expect(Boolean(bootstrap.is_manager)).toBeFalsy();
    expect(reason).toBeTruthy();
    expect(paymentSource).toBeTruthy();

    const createdExpense = await createExpense(staffApi, {
      amount: 12.34,
      expense_date: new Date().toISOString().slice(0, 10),
      payment_label: paymentSource.label,
      pos_profile: paymentSource.pos_profile || posProfile,
      reason_account: reason.account,
      remarks: `E2E expense ${timestampTag()}`,
    });

    const expense = createdExpense.expense;
    createdDocs.expenseRequests.push(expense.name);
    persistCreatedDocs();

    expect(Number(expense.docstatus)).toBe(0);
    expect(Boolean(expense.requires_approval)).toBeTruthy();

    const approveResponse = await staffApi.post(
      '/api/method/jarz_pos.api.expenses.approve_expense',
      { form: { name: expense.name } },
    );
    expect(approveResponse.status()).toBe(403);
    expect(await approveResponse.text()).toMatch(/Only managers can approve expenses/i);

    if (managerApi) {
      const approvedExpense = await approveExpense(managerApi, expense.name);
      expect(Number(approvedExpense.expense.docstatus)).toBe(1);
    }
  });

  test('phase 2: staff can pay an invoice by Instapay and upload a receipt @staff @write @phase2', async () => {
    await ensureManagedShift();
    const invoice = await createTrackedInvoice();
    const referenceNo = `IPY-${timestampTag()}`;
    const payment = await payInvoice(staffApi, {
      invoice_name: invoice.invoice_name,
      payment_mode: 'instapay',
      reference_date: new Date().toISOString().slice(0, 10),
      reference_no: referenceNo,
    });

    const paymentEntry = await getResource(
      verificationApi,
      'Payment Entry',
      payment.payment_entry,
    );
    const receipt = await createPaymentReceipt(staffApi, {
      amount: invoice.grand_total,
      payment_method: 'Instapay',
      pos_profile: posProfile,
      sales_invoice: invoice.invoice_name,
    });
    await uploadReceiptImage(staffApi, {
      filename: `e2e-receipt-${timestampTag()}.png`,
      image_data: tinyPngBase64,
      receipt_name: receipt.receipt_name,
    });
    const receiptDoc = await getResource(
      verificationApi,
      'POS Payment Receipt',
      receipt.receipt_name,
    );

    uploadedReceiptName = receipt.receipt_name;
    createdDocs.paymentEntries.push(paymentEntry.name);
    createdDocs.paymentReceipts.push(receipt.receipt_name);
    persistCreatedDocs();

    expect(String(paymentEntry.paid_to || '')).toContain('Bank Account');
    expect(String(paymentEntry.reference_no || '')).toBe(referenceNo);
    expect(String(receiptDoc.status || '')).toBe('Unconfirmed');
    expect(String(receiptDoc.receipt_image || receiptDoc.receipt_image_url || '')).not.toHaveLength(0);
  });

  test('phase 2: manager can confirm the uploaded Instapay receipt @staff @write @phase2', async () => {
    test.skip(!managerApi, 'Manager credentials are required to confirm uploaded payment receipts.');
    test.skip(!uploadedReceiptName, 'The Instapay receipt upload scenario must run before receipt confirmation.');

    await confirmReceipt(managerApi, uploadedReceiptName);
    const receiptDoc = await getResource(
      managerApi,
      'POS Payment Receipt',
      uploadedReceiptName,
    );

    expect(String(receiptDoc.status || '')).toBe('Confirmed');
    expect(String(receiptDoc.confirmed_by || '')).not.toHaveLength(0);
  });

  test('phase 2: staff can pay an invoice by Mobile Wallet @staff @write @phase2', async () => {
    await ensureManagedShift();
    const invoice = await createTrackedInvoice();
    const referenceNo = `WAL-${timestampTag()}`;
    const payment = await payInvoice(staffApi, {
      invoice_name: invoice.invoice_name,
      payment_mode: 'wallet',
      reference_date: new Date().toISOString().slice(0, 10),
      reference_no: referenceNo,
    });
    const paymentEntry = await getResource(
      verificationApi,
      'Payment Entry',
      payment.payment_entry,
    );

    createdDocs.paymentEntries.push(paymentEntry.name);
    persistCreatedDocs();

    expect(String(paymentEntry.paid_to || '')).toContain('Mobile Wallet');
    expect(String(paymentEntry.reference_no || '')).toBe(referenceNo);
  });

  test('phase 2: staff can assign a delivery slot to an invoice @staff @write @phase2', async () => {
    await ensureManagedShift();
    const slot = await getNextAvailableSlot(staffApi, posProfile);
    const invoice = await createTrackedInvoice();

    expect(slot).toBeTruthy();

    await updateInvoiceDeliverySlot(staffApi, {
      delivery_date: slot.date,
      delivery_duration: slotDurationSeconds(slot),
      delivery_slot_label: slot.label,
      delivery_time_from: slot.time,
      invoice_id: invoice.invoice_name,
    });

    const salesInvoice = await getResource(
      verificationApi,
      'Sales Invoice',
      invoice.invoice_name,
    );

    expect(String(salesInvoice.custom_delivery_date || '')).toBe(slot.date);
    expect(String(salesInvoice.custom_delivery_time_from || '')).toContain(slot.time);
    expect(numericValue(salesInvoice.custom_delivery_duration)).toBe(
      slotDurationSeconds(slot),
    );
  });

  test('phase 2: staff can create a pickup invoice path @staff @write @phase2', async () => {
    await ensureManagedShift();
    const invoice = await createTrackedInvoice({ pickup: true });
    const salesInvoice = await getResource(
      verificationApi,
      'Sales Invoice',
      invoice.invoice_name,
    );

    expect(numericValue(salesInvoice.custom_is_pickup)).toBe(1);
    expect(String(salesInvoice.custom_delivery_date || '')).toBe('');
    expect(String(salesInvoice.custom_delivery_time_from || '')).toBe('');
  });

  test('phase 2: staff can open courier balances without a permission error @staff @write @phase2', async () => {
    const balances = await getCourierBalances(staffApi);

    expect(balances).toBeDefined();
    expect(Array.isArray(balances) || typeof balances === 'object').toBeTruthy();
  });
});