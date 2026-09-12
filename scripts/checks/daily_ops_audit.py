"""Daily operations / staff-conduct audit for the Jarz POS site.

READ-ONLY. Runs under `bench --site frontend console` via scripts/remote_exec.ps1.

Emits one line per finding:

    ALERT <SEVERITY> <CODE> | <message>
    OK    <CODE> | <message>

Severities: HIGH (money at risk or a control bypassed), MED (a control is
lapsing), LOW (hygiene). The wrapper `scripts/run_daily_audit.ps1` filters on
the literal "ALERT"/"OK" prefix and writes a dated report.

`AUDIT_DAYS` is rewritten by the wrapper when -Days is passed; leave it at 1 so
the unattended 4 AM run covers the day that just ended.
"""

AUDIT_DAYS = 1

# --- thresholds -------------------------------------------------------------
TH_SHIFT_DIFF = 1000.0      # EGP: a single shift over/short worth explaining
TH_SHIFT_DIFF_HIGH = 3000.0  # EGP: a single shift over/short that is an incident
TH_COS_NET_DAY = 3000.0     # EGP: net Cash Over/Short booked in the window
TH_DRAWER_BAL = 20000.0     # EGP: cash left sitting in a branch drawer
TH_DRAWER_STALE_D = 2       # days with no GL movement = drawer not operated
TH_SHIFT_OPEN_H = 16        # hours a shift may stay open
TH_RCPT_AGE_H = 24          # hours an InstaPay receipt may sit unconfirmed
TH_UNPAID_AGE_D = 3         # days a delivered order may stay outstanding
TH_COURIER_AGE_H = 48       # hours a courier may hold collected cash
TH_STALE_CANCEL_H = 24      # hours after which a cancellation is "stale"
TH_AMEND_CHAIN = 2          # amendments on one order before it is churn
TH_AMEND_JUMP = 0.15        # fractional rise in total across an amendment
TH_STUCK_ORDER_H = 24       # hours in a non-terminal Kanban state
TH_IDLE_PRIVILEGED_D = 30   # days a manager-tier account may sit unused
TH_LOGIN_FAILS = 5          # failed logins for one identity

MANAGER_ROLES = (
    "JARZ Manager", "jarz line manager", "JARZ line manager", "System Manager",
    "Accounts Manager", "Stock Manager", "Purchase Manager", "POS Manager",
)

_findings = []


def alert(sev, code, msg):
    _findings.append((sev, code))
    print("JZAUDIT ALERT " + sev + " " + code + " | " + str(msg))


def ok(code, msg):
    print("JZAUDIT OK " + code + " | " + str(msg))


def check(code, fn):
    try:
        fn()
    except Exception as e:
        print("JZAUDIT ALERT LOW CHECK_FAILED | " + code + ": " + repr(e)[:300])


SINCE = frappe.utils.add_days(frappe.utils.nowdate(), -AUDIT_DAYS) + " 00:00:00"
print("JZAUDIT window " + SINCE + " .. " + frappe.utils.now()
      + "  (" + str(AUDIT_DAYS) + "d)")


# --- 1. Cash Over/Short: the drawer-to-expense leak -------------------------
def c_cash_over_short():
    rows = frappe.db.sql("""
        SELECT je.name, je.owner, je.posting_date, je.total_debit,
               LEFT(COALESCE(je.user_remark, je.remark, ''), 170) AS note
        FROM `tabJournal Entry` je
        WHERE je.creation >= %s AND je.docstatus = 1
          AND COALESCE(je.user_remark, je.remark, '') LIKE %s
        ORDER BY je.total_debit DESC
    """, (SINCE, "%Shift cash discrepancy%"), as_dict=True)
    worst = 0.0
    for r in rows:
        amt = r["total_debit"] or 0
        worst = max(worst, amt)
        if amt >= TH_SHIFT_DIFF_HIGH:
            alert("HIGH", "SHIFT_VARIANCE",
                  "%s %s booked %.0f EGP shift variance - %s"
                  % (r["posting_date"], r["owner"], amt, r["note"]))
        elif amt >= TH_SHIFT_DIFF:
            alert("MED", "SHIFT_VARIANCE",
                  "%s %s booked %.0f EGP shift variance - %s"
                  % (r["posting_date"], r["owner"], amt, r["note"]))
    if not rows:
        ok("SHIFT_VARIANCE", "no shift cash discrepancies booked")
    elif worst < TH_SHIFT_DIFF:
        ok("SHIFT_VARIANCE",
           "%d discrepancies, largest %.0f EGP, all under threshold"
           % (len(rows), worst))

    gl = frappe.db.sql("""
        SELECT ROUND(SUM(debit) - SUM(credit), 2) AS net, COUNT(*) AS n
        FROM `tabGL Entry`
        WHERE creation >= %s AND is_cancelled = 0 AND account LIKE %s
    """, (SINCE, "%Cash Over Short%"), as_dict=True)
    net = (gl[0]["net"] if gl and gl[0]["net"] is not None else 0) or 0
    if abs(net) >= TH_COS_NET_DAY:
        alert("HIGH", "CASH_OVER_SHORT_NET",
              "net %.0f EGP charged to Cash Over/Short over %d entries - this "
              "account is absorbing cash that belongs in a Cash Transfer or an "
              "Expense Request" % (net, gl[0]["n"]))
    else:
        ok("CASH_OVER_SHORT_NET", "net %.0f EGP" % net)


check("CASH_OVER_SHORT", c_cash_over_short)


# --- 2. Branch drawers ------------------------------------------------------
def c_drawers():
    rows = frappe.db.sql("""
        SELECT gle.account, ROUND(SUM(gle.debit) - SUM(gle.credit), 2) AS bal,
               MAX(gle.posting_date) AS last_entry,
               DATEDIFF(CURDATE(), MAX(gle.posting_date)) AS stale_d
        FROM `tabGL Entry` gle
        JOIN `tabAccount` a ON a.name = gle.account
        WHERE gle.is_cancelled = 0 AND a.account_type = 'Cash' AND a.is_group = 0
        GROUP BY gle.account
    """, as_dict=True)
    for r in rows:
        if (r["stale_d"] or 0) > TH_DRAWER_STALE_D and (r["bal"] or 0) > 0:
            alert("MED", "DRAWER_STALE",
                  "%s holds %.0f EGP with no movement for %d days - a drawer "
                  "that is not being operated is unrecorded cash"
                  % (r["account"], r["bal"], r["stale_d"]))
        elif (r["bal"] or 0) > TH_DRAWER_BAL and "Cash - " not in r["account"]:
            alert("MED", "DRAWER_HIGH",
                  "%s holds %.0f EGP - above the %.0f handover threshold"
                  % (r["account"], r["bal"], TH_DRAWER_BAL))
    if not _has("DRAWER"):
        ok("DRAWER", "%d cash accounts, all live and within threshold" % len(rows))


# --- 3. Shifts --------------------------------------------------------------
def c_shifts():
    op = frappe.db.sql("""
        SELECT name, `user`, pos_profile, period_start_date,
               TIMESTAMPDIFF(HOUR, period_start_date, NOW()) AS open_h
        FROM `tabPOS Opening Entry`
        WHERE status = 'Open' AND docstatus < 2
        ORDER BY period_start_date
    """, as_dict=True)
    for r in op:
        if (r["open_h"] or 0) > TH_SHIFT_OPEN_H:
            alert("MED", "SHIFT_LEFT_OPEN",
                  "%s (%s) open %dh since %s - close it or the next count is "
                  "measured against the wrong balance"
                  % (r["name"], r["pos_profile"], r["open_h"],
                     r["period_start_date"]))
    profiles = [p["name"] for p in frappe.db.sql(
        "SELECT name FROM `tabPOS Profile` WHERE disabled = 0", as_dict=True)]
    opened = set(x["pos_profile"] for x in frappe.db.sql("""
        SELECT DISTINCT pos_profile FROM `tabPOS Opening Entry`
        WHERE creation >= %s
    """, (SINCE,), as_dict=True))
    sold = set(x["pos_profile"] for x in frappe.db.sql("""
        SELECT DISTINCT pos_profile FROM `tabSales Invoice`
        WHERE creation >= %s AND docstatus = 1 AND pos_profile IS NOT NULL
    """, (SINCE,), as_dict=True))
    for p in profiles:
        if p in sold and p not in opened:
            alert("HIGH", "SOLD_WITHOUT_SHIFT",
                  "%s took orders with no shift opened in the window" % p)
    if not _has("SHIFT_LEFT_OPEN") and not _has("SOLD_WITHOUT_SHIFT"):
        ok("SHIFTS", "%d open shift(s), all within %dh; every selling branch "
           "opened a shift" % (len(op), TH_SHIFT_OPEN_H))


# --- 4. InstaPay / wallet receipts -----------------------------------------
def c_receipts():
    rows = frappe.db.sql("""
        SELECT name, sales_invoice, amount, pos_profile, uploaded_by, creation,
               TIMESTAMPDIFF(HOUR, creation, NOW()) AS age_h
        FROM `tabPOS Payment Receipt`
        WHERE status = 'Unconfirmed'
        ORDER BY creation
    """, as_dict=True)
    stale = [r for r in rows if (r["age_h"] or 0) > TH_RCPT_AGE_H]
    if stale:
        amt = sum(r["amount"] or 0 for r in stale)
        alert("HIGH", "RECEIPT_UNCONFIRMED",
              "%d receipts worth %.0f EGP unconfirmed for more than %dh "
              "(oldest %dh, %s) - the invoices stay outstanding until someone "
              "confirms them"
              % (len(stale), amt, TH_RCPT_AGE_H, stale[0]["age_h"] or 0,
                 stale[0]["sales_invoice"]))
        for r in stale[:12]:
            print("JZAUDIT     - %s %s %.0f EGP %s by %s (%dh)"
                  % (r["name"], r["sales_invoice"], r["amount"] or 0,
                     r["pos_profile"], r["uploaded_by"], r["age_h"] or 0))
    else:
        ok("RECEIPT_UNCONFIRMED", "%d unconfirmed, none older than %dh"
           % (len(rows), TH_RCPT_AGE_H))
    last = frappe.db.sql(
        "SELECT MAX(confirmed_date) AS d FROM `tabPOS Payment Receipt`",
        as_dict=True)
    if last and last[0]["d"]:
        age = frappe.utils.time_diff_in_hours(frappe.utils.now(), str(last[0]["d"]))
        if age > 48:
            alert("MED", "RECEIPT_REVIEW_LAPSED",
                  "no receipt has been confirmed by anyone for %.0fh (last %s)"
                  % (age, last[0]["d"]))


# --- 5. Delivered but unpaid ------------------------------------------------
def c_unpaid():
    rows = frappe.db.sql("""
        SELECT name, owner, pos_profile, customer, outstanding_amount,
               custom_payment_method AS pm, custom_sales_invoice_state AS state,
               posting_date, DATEDIFF(CURDATE(), posting_date) AS age_d
        FROM `tabSales Invoice`
        WHERE docstatus = 1 AND is_return = 0 AND outstanding_amount > 0
          AND posting_date < CURDATE() - INTERVAL %s DAY
        ORDER BY posting_date LIMIT 100
    """, (TH_UNPAID_AGE_D,), as_dict=True)
    if rows:
        amt = sum(r["outstanding_amount"] or 0 for r in rows)
        sev = "HIGH" if amt > 10000 else "MED"
        alert(sev, "AGED_UNPAID",
              "%d delivered orders still outstanding for more than %dd, "
              "%.0f EGP total (oldest %s, %dd)"
              % (len(rows), TH_UNPAID_AGE_D, amt, rows[0]["name"],
                 rows[0]["age_d"] or 0))
        for r in rows[:12]:
            print("JZAUDIT     - %s %s %.0f EGP %s/%s %dd"
                  % (r["name"], r["pos_profile"], r["outstanding_amount"] or 0,
                     r["pm"], r["state"], r["age_d"] or 0))
    else:
        ok("AGED_UNPAID", "nothing outstanding beyond %dd" % TH_UNPAID_AGE_D)


# --- 6. Courier float + segregation of duties -------------------------------
def c_courier():
    rows = frappe.db.sql("""
        SELECT party_type, party, COUNT(*) AS n, ROUND(SUM(amount), 2) AS amt,
               MIN(date) AS oldest,
               TIMESTAMPDIFF(HOUR, MIN(date), NOW()) AS age_h
        FROM `tabCourier Transaction`
        WHERE COALESCE(status, '') != 'Settled'
        GROUP BY party_type, party ORDER BY amt DESC
    """, as_dict=True)
    for r in rows:
        if (r["age_h"] or 0) > TH_COURIER_AGE_H:
            alert("MED", "COURIER_FLOAT",
                  "%s %s holds %.0f EGP over %d orders, oldest %dh"
                  % (r["party_type"], r["party"], r["amt"] or 0, r["n"],
                     r["age_h"] or 0))
    self_settled = frappe.db.sql("""
        SELECT owner, COUNT(*) AS n, ROUND(SUM(amount), 2) AS amt
        FROM `tabCourier Transaction`
        WHERE creation >= %s AND status = 'Settled' AND owner = modified_by
        GROUP BY owner ORDER BY amt DESC
    """, (SINCE,), as_dict=True)
    for r in self_settled:
        alert("MED", "COURIER_SELF_SETTLE",
              "%s recorded AND settled %d courier handovers worth %.0f EGP - "
              "the person who books the debt should not be the one clearing it"
              % (r["owner"], r["n"], r["amt"] or 0))
    mixed = frappe.db.sql("""
        SELECT COUNT(DISTINCT party_type) AS n FROM `tabCourier Transaction`
        WHERE creation >= %s
    """, (SINCE,), as_dict=True)
    if mixed and (mixed[0]["n"] or 0) > 1:
        alert("LOW", "COURIER_IDENTITY_SPLIT",
              "couriers are booked against more than one party type "
              "(Employee and Supplier) - the same person can carry two balances")
    if not rows and not self_settled:
        ok("COURIER", "no courier float beyond %dh, no self-settlement"
           % TH_COURIER_AGE_H)


# --- 7. Cancellations and amendment churn ----------------------------------
def c_cancel_amend():
    canc = frappe.db.sql("""
        SELECT name, owner, modified_by, pos_profile, grand_total, creation,
               modified, TIMESTAMPDIFF(HOUR, creation, modified) AS h
        FROM `tabSales Invoice`
        WHERE docstatus = 2 AND modified >= %s ORDER BY h DESC
    """, (SINCE,), as_dict=True)
    for r in canc:
        if (r["h"] or 0) > TH_STALE_CANCEL_H:
            alert("MED", "STALE_CANCEL",
                  "%s (%s, %.0f EGP) cancelled by %s %dh after it was raised - "
                  "this rewrites a day that was already counted"
                  % (r["name"], r["pos_profile"], r["grand_total"] or 0,
                     r["modified_by"], r["h"] or 0))
    if canc:
        ok("CANCEL_VOLUME", "%d cancellations in the window, %.0f EGP"
           % (len(canc), sum(r["grand_total"] or 0 for r in canc)))
    else:
        ok("CANCEL_VOLUME", "no cancellations")

    am = frappe.db.sql("""
        SELECT si.name, si.amended_from, si.owner, si.modified_by,
               si.pos_profile, si.grand_total, prev.grand_total AS prev_total
        FROM `tabSales Invoice` si
        JOIN `tabSales Invoice` prev ON prev.name = si.amended_from
        WHERE si.creation >= %s
    """, (SINCE,), as_dict=True)
    for r in am:
        root = (r["name"] or "").split("-")
        depth = 0
        try:
            depth = int(root[-1]) if root[-1].isdigit() and len(root) > 3 else 0
        except Exception:
            depth = 0
        if depth >= TH_AMEND_CHAIN:
            alert("MED", "AMEND_CHURN",
                  "%s is amendment #%d of the same order (%s) - each cycle "
                  "cancels and re-books the stock and the courier leg"
                  % (r["name"], depth, r["pos_profile"]))
        prev = r["prev_total"] or 0
        cur = r["grand_total"] or 0
        if prev > 0 and cur > prev * (1 + TH_AMEND_JUMP):
            alert("HIGH", "AMEND_INFLATION",
                  "%s rose from %.0f to %.0f EGP on amendment (+%.0f%%) by %s - "
                  "check for duplicated bundle lines before it is delivered"
                  % (r["name"], prev, cur, (cur / prev - 1) * 100,
                     r["modified_by"]))
    if not am:
        ok("AMEND", "no amendments")


# --- 8. Cash paid out of a drawer without an expense request ----------------
def c_handbuilt_je():
    rows = frappe.db.sql("""
        SELECT je.name, je.owner, je.posting_date, je.total_debit,
               LEFT(COALESCE(je.user_remark, je.remark, ''), 150) AS note
        FROM `tabJournal Entry` je
        WHERE je.creation >= %s AND je.docstatus = 1
          AND COALESCE(je.custom_jarz_je_tag, '') = ''
          AND COALESCE(je.user_remark, je.remark, '') NOT LIKE %s
          AND COALESCE(je.user_remark, je.remark, '') NOT LIKE %s
          AND COALESCE(je.user_remark, je.remark, '') NOT LIKE %s
          AND EXISTS (
              SELECT 1 FROM `tabJournal Entry Account` jea
              JOIN `tabAccount` a ON a.name = jea.account
              WHERE jea.parent = je.name AND a.account_type = 'Cash'
                AND jea.credit > 0)
        ORDER BY je.total_debit DESC
    """, (SINCE, "%JARZ-JE:%", "%Shift cash discrepancy%", "%Expense JEXP%"),
        as_dict=True)
    for r in rows:
        alert("HIGH", "CASH_OUT_NO_REQUEST",
              "%s paid %.0f EGP out of a cash account on a hand-written "
              "journal entry by %s - no Expense Request, no approval trail "
              "(remark: %s)"
              % (r["name"], r["total_debit"] or 0, r["owner"],
                 r["note"] or "(blank)"))
    if not rows:
        ok("CASH_OUT_NO_REQUEST",
           "every cash payout went through the expense or settlement flow")


# --- 9. Backdating ----------------------------------------------------------
def c_backdate():
    for dt, label in (("Sales Invoice", "invoice"), ("Stock Entry", "stock entry"),
                      ("Journal Entry", "journal entry")):
        rows = frappe.db.sql("""
            SELECT name, owner, posting_date, creation,
                   DATEDIFF(DATE(creation), posting_date) AS d
            FROM `tab""" + dt + """`
            WHERE creation >= %s AND docstatus = 1
              AND DATEDIFF(DATE(creation), posting_date) > 1
            ORDER BY d DESC LIMIT 20
        """, (SINCE,), as_dict=True)
        for r in rows:
            alert("MED", "BACKDATED",
                  "%s %s posted %d days in the past by %s (posted %s, entered %s)"
                  % (label, r["name"], r["d"], r["owner"], r["posting_date"],
                     str(r["creation"])[:16]))
    if not _has("BACKDATED"):
        ok("BACKDATED", "nothing posted more than a day before it was entered")


# --- 10. Attendance / roster ------------------------------------------------
def c_attendance():
    assigned = frappe.db.sql("""
        SELECT COUNT(*) AS n FROM `tabShift Assignment`
        WHERE docstatus < 2 AND %s BETWEEN start_date
              AND COALESCE(end_date, '2099-12-31')
    """, (frappe.utils.nowdate(),), as_dict=True)[0]["n"]
    checkins = frappe.db.sql("""
        SELECT COUNT(*) AS n FROM `tabEmployee Checkin` WHERE `time` >= %s
    """, (SINCE,), as_dict=True)[0]["n"]
    if not assigned:
        alert("MED", "ROSTER_EMPTY",
              "no Shift Assignment covers today - the geofenced check-in gate "
              "has nothing to measure against, so anyone can clock in anywhere")
    else:
        ok("ROSTER", "%d shift assignments cover today" % assigned)
    if not checkins:
        alert("MED", "NO_CHECKINS",
              "zero employee check-ins in the window - attendance is not being "
              "recorded, so rostered hours and overtime cannot be verified")
    else:
        ok("CHECKINS", "%d check-ins" % checkins)


# --- 11. Access hygiene -----------------------------------------------------
def c_access():
    marks = ",".join(["%s"] * len(MANAGER_ROLES))
    rows = frappe.db.sql("""
        SELECT u.name, u.full_name,
               DATEDIFF(CURDATE(), DATE(COALESCE(u.last_active, u.creation))) AS idle_d,
               GROUP_CONCAT(DISTINCT r.role SEPARATOR ', ') AS roles
        FROM `tabUser` u JOIN `tabHas Role` r ON r.parent = u.name
        WHERE u.enabled = 1 AND u.name NOT IN ('Administrator', 'Guest')
          AND r.role IN (""" + marks + """)
        GROUP BY u.name HAVING idle_d > %s ORDER BY idle_d DESC
    """, tuple(MANAGER_ROLES) + (TH_IDLE_PRIVILEGED_D,), as_dict=True)
    for r in rows:
        alert("MED", "DORMANT_PRIVILEGED",
              "%s (%s) has not used the system for %d days but still holds: %s"
              % (r["name"], r["full_name"], r["idle_d"], r["roles"]))
    changed = frappe.db.sql("""
        SELECT docname, owner, creation FROM `tabVersion`
        WHERE ref_doctype = 'User' AND creation >= %s
          AND data LIKE %s ORDER BY creation DESC
    """, (SINCE, "%\"roles\"%"), as_dict=True)
    for r in changed:
        alert("MED", "ROLE_CHANGED",
              "roles on %s were changed by %s at %s - confirm it was intended"
              % (r["docname"], r["owner"], str(r["creation"])[:16]))
    fails = frappe.db.sql("""
        SELECT `user`, COUNT(*) AS n FROM `tabActivity Log`
        WHERE creation >= %s AND status = 'Failed'
        GROUP BY `user` HAVING n >= %s ORDER BY n DESC
    """, (SINCE, TH_LOGIN_FAILS), as_dict=True)
    for r in fails:
        alert("LOW", "LOGIN_FAILURES",
              "%d failed logins for '%s'" % (r["n"], r["user"]))
    if not rows and not changed and not fails:
        ok("ACCESS", "no dormant privileged accounts, role changes or login storms")


# --- 12. Orders stuck mid-flow ---------------------------------------------
def c_stuck():
    rows = frappe.db.sql("""
        SELECT name, pos_profile, customer, grand_total,
               custom_sales_invoice_state AS state, posting_date,
               TIMESTAMPDIFF(HOUR, creation, NOW()) AS age_h
        FROM `tabSales Invoice`
        WHERE docstatus = 1 AND is_return = 0
          AND custom_sales_invoice_state IN
              ('Recieved', 'Received', 'In Progress', 'Ready', 'Out for Delivery')
          AND TIMESTAMPDIFF(HOUR, creation, NOW()) > %s
        ORDER BY creation LIMIT 40
    """, (TH_STUCK_ORDER_H,), as_dict=True)
    if rows:
        alert("MED", "STUCK_ORDER",
              "%d orders have sat in a non-terminal state for over %dh "
              "(oldest %s, %s, %dh)"
              % (len(rows), TH_STUCK_ORDER_H, rows[0]["name"],
                 rows[0]["state"], rows[0]["age_h"] or 0))
        for r in rows[:10]:
            print("JZAUDIT     - %s %s %s %.0f EGP %dh"
                  % (r["name"], r["pos_profile"], r["state"],
                     r["grand_total"] or 0, r["age_h"] or 0))
    else:
        ok("STUCK_ORDER", "no order stuck beyond %dh" % TH_STUCK_ORDER_H)


# --- 13. Discounting --------------------------------------------------------
def c_discount():
    hdr = frappe.db.sql("""
        SELECT name, owner, pos_profile, grand_total, discount_amount,
               additional_discount_percentage AS pct
        FROM `tabSales Invoice`
        WHERE creation >= %s AND docstatus = 1
          AND (COALESCE(discount_amount, 0) > 0
               OR COALESCE(additional_discount_percentage, 0) > 0)
        ORDER BY discount_amount DESC LIMIT 30
    """, (SINCE,), as_dict=True)
    for r in hdr:
        alert("LOW", "INVOICE_DISCOUNT",
              "%s (%s) carries a %.0f EGP / %.1f%% invoice discount applied by %s"
              % (r["name"], r["pos_profile"], r["discount_amount"] or 0,
                 r["pct"] or 0, r["owner"]))
    # rate < price list, excluding zero-rated bundle PARENT lines, which are
    # priced at 0 by design with the child items carrying the value
    lines = frappe.db.sql("""
        SELECT si.name, si.owner, sii.item_code, sii.qty, sii.rate,
               sii.price_list_rate
        FROM `tabSales Invoice Item` sii
        JOIN `tabSales Invoice` si ON si.name = sii.parent
        WHERE si.creation >= %s AND si.docstatus = 1
          AND COALESCE(sii.price_list_rate, 0) > 0 AND sii.rate > 0
          AND sii.rate < sii.price_list_rate * 0.95
        ORDER BY (sii.price_list_rate - sii.rate) * sii.qty DESC LIMIT 30
    """, (SINCE,), as_dict=True)
    for r in lines:
        gap = (r["price_list_rate"] - r["rate"]) * r["qty"]
        alert("MED", "LINE_UNDERPRICED",
              "%s: %s sold at %.0f vs list %.0f (%.0f EGP below list) by %s"
              % (r["name"], r["item_code"], r["rate"], r["price_list_rate"],
                 gap, r["owner"]))
    if not hdr and not lines:
        ok("DISCOUNT", "no invoice discounts and no line priced below list")


def _has(prefix):
    return any(c.startswith(prefix) for _s, c in _findings)


check("DRAWERS", c_drawers)
check("SHIFTS", c_shifts)
check("RECEIPTS", c_receipts)
check("UNPAID", c_unpaid)
check("COURIER", c_courier)
check("CANCEL_AMEND", c_cancel_amend)
check("HANDBUILT_JE", c_handbuilt_je)
check("BACKDATE", c_backdate)
check("ATTENDANCE", c_attendance)
check("ACCESS", c_access)
check("STUCK", c_stuck)
check("DISCOUNT", c_discount)

_high = sum(1 for s, _c in _findings if s == "HIGH")
_med = sum(1 for s, _c in _findings if s == "MED")
_low = sum(1 for s, _c in _findings if s == "LOW")
print("JZAUDIT SUMMARY high=%d med=%d low=%d total=%d"
      % (_high, _med, _low, len(_findings)))
