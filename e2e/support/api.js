const { expect, request } = require('@playwright/test');
const { optionalEnv, requireEnv } = require('./env');

const tinyPngBase64 =
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjWQAAAABJRU5ErkJggg==';

function timestampTag() {
  return new Date().toISOString().replace(/[-:TZ.]/g, '').slice(0, 14);
}

function numericValue(value, fallback = 0) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function withQuery(path, params = {}) {
  const query = new URLSearchParams();

  for (const [key, value] of Object.entries(params)) {
    if (value === undefined || value === null || value === '') {
      continue;
    }

    query.set(key, String(value));
  }

  const serialized = query.toString();
  return serialized ? `${path}?${serialized}` : path;
}

async function readPayload(response) {
  const text = await response.text();
  if (!text) {
    return {};
  }

  try {
    return JSON.parse(text);
  } catch {
    return { raw: text };
  }
}

function unwrapMessage(payload) {
  if (payload && typeof payload === 'object' && payload.message !== undefined) {
    return payload.message;
  }

  return payload;
}

async function createAuthenticatedContext(
  baseURL,
  userEnv = 'E2E_USER',
  passwordEnv = 'E2E_PASSWORD',
) {
  const apiContext = await request.newContext({
    baseURL,
    extraHTTPHeaders: {
      Accept: 'application/json',
    },
  });

  const loginResponse = await apiContext.post('/api/method/login', {
    form: {
      usr: requireEnv(userEnv),
      pwd: requireEnv(passwordEnv),
    },
  });

  expect(loginResponse.ok()).toBeTruthy();
  return apiContext;
}

async function getJson(apiContext, path, params = {}) {
  const response = await apiContext.get(withQuery(path, params));
  const payload = await readPayload(response);
  return {
    message: unwrapMessage(payload),
    payload,
    response,
  };
}

async function postForm(apiContext, path, form = {}) {
  const response = await apiContext.post(path, { form });
  const payload = await readPayload(response);
  return {
    message: unwrapMessage(payload),
    payload,
    response,
  };
}

async function getPosProfiles(apiContext) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.pos.get_pos_profiles',
  );
  expect(response.ok()).toBeTruthy();

  return (Array.isArray(message) ? message : [])
    .map((profile) => {
      if (typeof profile === 'string') {
        return {
          allowDeliveryPartner: false,
          name: profile,
        };
      }

      return {
        allowDeliveryPartner: profile.allow_delivery_partner === true,
        name: String(profile.name || ''),
      };
    })
    .filter((profile) => profile.name);
}

async function getProfileProducts(apiContext, posProfile) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.pos.get_profile_products',
    { profile: posProfile },
  );
  expect(response.ok()).toBeTruthy();
  return Array.isArray(message) ? message : [];
}

function pickSellableItem(items) {
  const candidates = Array.isArray(items) ? items : [];
  const inStock = candidates
    .filter((item) => numericValue(item.qty ?? item.actual_qty, 0) > 0)
    .sort(
      (left, right) =>
        numericValue(right.qty ?? right.actual_qty, 0) -
        numericValue(left.qty ?? left.actual_qty, 0),
    );

  if (inStock.length > 0) {
    return inStock[0];
  }

  return candidates[0] || null;
}

async function getTerritories(apiContext, search = '') {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.customer.get_territories',
    search ? { search } : {},
  );
  expect(response.ok()).toBeTruthy();
  return Array.isArray(message) ? message : [];
}

async function getActiveShift(apiContext, posProfile) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.shift.get_active_shift',
    { pos_profile: posProfile },
  );
  expect(response.ok()).toBeTruthy();
  return message && typeof message === 'object' ? message : null;
}

async function getShiftPaymentMethods(apiContext, posProfile) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.shift.get_shift_payment_methods',
    { pos_profile: posProfile },
  );
  expect(response.ok()).toBeTruthy();
  return Array.isArray(message) ? message : [];
}

async function startShift(apiContext, posProfile, openingBalances) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.shift.start_shift',
    {
      opening_balances: JSON.stringify(openingBalances),
      pos_profile: posProfile,
    },
  );
  expect(response.ok()).toBeTruthy();
  expect(message.opening_entry).toBeTruthy();
  return message;
}

async function getShiftSummary(apiContext, openingEntry) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.shift.get_shift_summary',
    { pos_opening_entry: openingEntry },
  );
  expect(response.ok()).toBeTruthy();
  return message;
}

async function endShift(apiContext, openingEntry, closingBalances) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.shift.end_shift',
    {
      closing_balances: JSON.stringify(closingBalances),
      pos_opening_entry: openingEntry,
    },
  );
  expect(response.ok()).toBeTruthy();
  return message;
}

async function searchCustomers(apiContext, query) {
  const trimmed = String(query || '').trim();
  const isPhoneSearch = /^[0-9+\-\s()]+$/.test(trimmed);
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.customer.search_customers',
    isPhoneSearch ? { phone: trimmed } : { name: trimmed },
  );
  expect(response.ok()).toBeTruthy();
  return Array.isArray(message) ? message : [];
}

async function createCustomer(apiContext, customerInput) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.customer.create_customer',
    customerInput,
  );
  expect(response.ok()).toBeTruthy();
  return message;
}

async function getCustomerShippingAddresses(apiContext, customerName) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.customer.get_customer_shipping_addresses',
    { customer: customerName },
  );
  expect(response.ok()).toBeTruthy();
  return message;
}

function buildStaffCustomerInput(territoryId) {
  const stamp = timestampTag();
  const phoneTail = stamp.slice(-8);

  return {
    customer_name: `E2E Staff ${stamp}`,
    customer_primary_address: `E2E Address ${stamp}`,
    location_link: `https://maps.example/${stamp}`,
    mobile_no: `015${phoneTail}`,
    secondary_mobile: `012${phoneTail}`,
    territory_id: territoryId,
  };
}

function buildSingleItemCart(item, quantity = 1) {
  return [
    {
      item_code: String(item.item_code || item.id || item.name || ''),
      quantity,
      rate: numericValue(item.rate ?? item.price ?? item.price_list_rate, 1),
    },
  ];
}

function buildInvoiceForm({
  customerName,
  deliveryEndDatetime,
  paymentMethod,
  paymentType,
  posProfile,
  requiredDeliveryDatetime,
  shippingAddressName,
  cartItems,
  pickup = false,
}) {
  return {
    cart_json: JSON.stringify(cartItems),
    customer_name: customerName || 'Walking Customer',
    pos_profile_name: posProfile,
    ...(deliveryEndDatetime ? { delivery_end_datetime: deliveryEndDatetime } : {}),
    ...(paymentMethod ? { payment_method: paymentMethod } : {}),
    ...(paymentType ? { payment_type: paymentType } : {}),
    ...(pickup ? { pickup: 1 } : {}),
    ...(requiredDeliveryDatetime
      ? { required_delivery_datetime: requiredDeliveryDatetime }
      : {}),
    ...(shippingAddressName ? { shipping_address_name: shippingAddressName } : {}),
  };
}

async function createPosInvoice(apiContext, invoiceForm) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.invoices.create_pos_invoice',
    invoiceForm,
  );
  expect(response.ok()).toBeTruthy();
  expect(message.invoice_name).toBeTruthy();
  return message;
}

async function payInvoice(apiContext, paymentForm) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.invoices.pay_invoice',
    paymentForm,
  );
  expect(response.ok()).toBeTruthy();
  expect(message.payment_entry).toBeTruthy();
  return message;
}

async function getExpenseBootstrap(apiContext) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.expenses.get_expense_bootstrap',
    { filters: '{}' },
  );
  expect(response.ok()).toBeTruthy();
  return message;
}

async function createExpense(apiContext, expenseForm) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.expenses.create_expense',
    expenseForm,
  );
  expect(response.ok()).toBeTruthy();
  expect(message.expense).toBeTruthy();
  return message;
}

async function approveExpense(apiContext, expenseName) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.expenses.approve_expense',
    { name: expenseName },
  );
  expect(response.ok()).toBeTruthy();
  expect(message.expense).toBeTruthy();
  return message;
}

async function getNextAvailableSlot(apiContext, posProfile) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.delivery_slots.get_next_available_slot',
    { pos_profile_name: posProfile },
  );
  expect(response.ok()).toBeTruthy();
  return message;
}

function slotDurationSeconds(slot) {
  const startTime = Date.parse(slot.datetime || '');
  const endTime = Date.parse(slot.end_datetime || '');
  if (Number.isFinite(startTime) && Number.isFinite(endTime) && endTime > startTime) {
    return Math.round((endTime - startTime) / 1000);
  }

  return 3600;
}

async function updateInvoiceDeliverySlot(apiContext, slotForm) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.invoices.update_invoice_delivery_slot',
    slotForm,
  );
  expect(response.ok()).toBeTruthy();
  expect(message.success).toBeTruthy();
  return message;
}

async function getCourierBalances(apiContext) {
  const { response, message } = await getJson(
    apiContext,
    '/api/method/jarz_pos.api.couriers.get_courier_balances',
  );
  expect(response.ok()).toBeTruthy();
  return message;
}

async function createPaymentReceipt(apiContext, receiptForm) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.payment_receipts.create_payment_receipt',
    receiptForm,
  );
  expect(response.ok()).toBeTruthy();
  expect(message.receipt_name).toBeTruthy();
  return message;
}

async function uploadReceiptImage(apiContext, uploadForm) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.payment_receipts.upload_receipt_image',
    uploadForm,
  );
  expect(response.ok()).toBeTruthy();
  expect(message.file_url).toBeTruthy();
  return message;
}

async function confirmReceipt(apiContext, receiptName) {
  const { response, message } = await postForm(
    apiContext,
    '/api/method/jarz_pos.api.payment_receipts.confirm_receipt',
    { receipt_name: receiptName },
  );
  expect(response.ok()).toBeTruthy();
  expect(message.success).toBeTruthy();
  return message;
}

async function getResource(apiContext, doctype, name) {
  const { response, payload } = await getJson(
    apiContext,
    `/api/resource/${encodeURIComponent(doctype)}/${encodeURIComponent(name)}`,
  );
  expect(response.ok()).toBeTruthy();
  return payload.data || payload;
}

async function listResources(
  apiContext,
  doctype,
  { fields = ['name'], filters = [], limit = 20, orderBy } = {},
) {
  const { response, payload } = await getJson(
    apiContext,
    `/api/resource/${encodeURIComponent(doctype)}`,
    {
      fields: JSON.stringify(fields),
      filters: JSON.stringify(filters),
      limit_page_length: limit,
      ...(orderBy ? { order_by: orderBy } : {}),
    },
  );
  expect(response.ok()).toBeTruthy();
  return Array.isArray(payload.data) ? payload.data : [];
}

async function findLinkedPaymentEntry(apiContext, invoiceName) {
  const references = await listResources(apiContext, 'Payment Entry Reference', {
    fields: ['parent'],
    filters: [
      ['reference_doctype', '=', 'Sales Invoice'],
      ['reference_name', '=', invoiceName],
    ],
    limit: 5,
  });

  if (references.length === 0) {
    return null;
  }

  return getResource(apiContext, 'Payment Entry', references[0].parent);
}

module.exports = {
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
  readPayload,
  searchCustomers,
  slotDurationSeconds,
  startShift,
  timestampTag,
  tinyPngBase64,
  updateInvoiceDeliverySlot,
  uploadReceiptImage,
};