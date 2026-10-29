// Customer follow-ups (reorder plan): the rows and payloads of
// `jarz_pos.api.customer_followups`. Plain classes with hand-written,
// defensive `fromJson` — the same loosely-typed parsing the reports feature
// uses, because Frappe sends ints as bool / num / str depending on the field
// type and leaves keys out when they are empty.

/// Lenient int: `true`/`false`, `3`, `3.0`, `"3"`, `"3.0"`, `null`.
int followupInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is bool) return value ? 1 : 0;
  if (value is num) return value.toInt();
  final text = value.toString().trim();
  if (text.isEmpty) return fallback;
  final lower = text.toLowerCase();
  if (lower == 'true') return 1;
  if (lower == 'false') return 0;
  return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? fallback;
}

/// Lenient double, same inputs as [followupInt].
double followupDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is bool) return value ? 1 : 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim()) ?? fallback;
}

/// Lenient flag: anything [followupInt] reads as non-zero.
bool followupBool(dynamic value) => followupInt(value) != 0;

/// Lenient string: `null` becomes [fallback], everything else `toString()`.
String followupString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

Map<String, int> _countMap(dynamic value) {
  if (value is! Map) return const <String, int>{};
  return {
    for (final entry in value.entries)
      entry.key.toString(): followupInt(entry.value),
  };
}

/// The touch channels the backend schedules.
enum FollowupChannel { message, call }

/// Outcomes `log_touch` accepts, with their wire values.
enum FollowupOutcome {
  happy('Happy'),
  quality('Quality'),
  delivery('Delivery'),
  noReply('No Reply'),
  optedOut('Opted Out');

  const FollowupOutcome(this.wire);
  final String wire;

  /// Outcomes that take the customer out of the cycle and so need a confirm.
  bool get leavesCycle =>
      this == FollowupOutcome.quality || this == FollowupOutcome.optedOut;

  static FollowupOutcome? fromWire(String? value) {
    for (final o in FollowupOutcome.values) {
      if (o.wire == value) return o;
    }
    return null;
  }
}

/// Values of `log_touch.reached` (Calls only).
enum FollowupReach {
  reached('Reached'),
  notReached('Not Reached');

  const FollowupReach(this.wire);
  final String wire;
}

/// `summary` of `get_followups_today`.
class FollowupSummary {
  final int due;
  final int overdue;
  final int calls;
  final int messages;

  const FollowupSummary({
    this.due = 0,
    this.overdue = 0,
    this.calls = 0,
    this.messages = 0,
  });

  factory FollowupSummary.fromJson(dynamic json) {
    if (json is! Map) return const FollowupSummary();
    return FollowupSummary(
      due: followupInt(json['due']),
      overdue: followupInt(json['overdue']),
      calls: followupInt(json['calls']),
      messages: followupInt(json['messages']),
    );
  }

  /// The summary once [row] has been handled (logged or skipped), so the
  /// chips stay truthful without a reload. Never goes below zero.
  FollowupSummary without(FollowupRow row) {
    int dec(int v) => v > 0 ? v - 1 : 0;
    return FollowupSummary(
      due: dec(due),
      overdue: row.isOverdue ? dec(overdue) : overdue,
      calls: row.isCall ? dec(calls) : calls,
      messages: row.isCall ? messages : dec(messages),
    );
  }
}

/// One due touch from `get_followups_today.rows`.
class FollowupRow {
  final String name;
  final String customer;
  final String customerName;
  final String phone;

  /// Digits like `2010xxxxxxx`; may be empty.
  final String whatsappMsisdn;

  /// Pre-rendered Arabic script / message for this step.
  final String messageText;

  /// Claude-written WhatsApp message, cached server-side; empty if none.
  final String aiMessage;

  /// Claude-written brief about the customer for before the call; empty if none.
  final String aiBrief;

  /// The plain template message (what `messageText` falls back to).
  final String templateText;

  /// `3h`, `day2`, `day7`, `day30`, `day32`, `day45`, `day50`.
  final String step;
  final FollowupChannel channel;

  /// Raw `"YYYY-MM-DD HH:MM:SS"` from the server.
  final String dueAtRaw;
  final bool isOverdue;

  /// `New` | `Repeat`.
  final String customerType;

  /// `High` | `Low`.
  final String valueBand;
  final double orderValue;
  final String invoice;
  final int wooOrderId;
  final int lifetimeOrders;
  final String? customerSegment;
  final bool rfmIsRegular;
  final String territory;

  /// Server-built line saying why the touch is due (last order, order count, items).
  final String reason;

  /// Touch status as the server names it (e.g. `Pending`); may be empty.
  final String status;

  /// `Reached` | `Not Reached` once a call was logged; empty otherwise.
  final String reached;

  /// Logged outcome wire value; empty while pending.
  final String outcome;
  final String notes;
  final String? apologyCode;
  final String? escalationTask;

  const FollowupRow({
    required this.name,
    this.customer = '',
    this.customerName = '',
    this.phone = '',
    this.whatsappMsisdn = '',
    this.messageText = '',
    this.aiMessage = '',
    this.aiBrief = '',
    this.templateText = '',
    this.step = '',
    this.channel = FollowupChannel.message,
    this.dueAtRaw = '',
    this.isOverdue = false,
    this.customerType = '',
    this.valueBand = '',
    this.orderValue = 0,
    this.invoice = '',
    this.wooOrderId = 0,
    this.lifetimeOrders = 0,
    this.customerSegment,
    this.rfmIsRegular = false,
    this.territory = '',
    this.reason = '',
    this.status = '',
    this.reached = '',
    this.outcome = '',
    this.notes = '',
    this.apologyCode,
    this.escalationTask,
  });

  factory FollowupRow.fromJson(Map<String, dynamic> json) {
    final channelRaw = followupString(json['channel']).trim().toLowerCase();
    return FollowupRow(
      name: followupString(json['name']),
      customer: followupString(json['customer']),
      customerName: followupString(json['customer_name']),
      phone: followupString(json['phone']).trim(),
      whatsappMsisdn: followupString(json['whatsapp_msisdn']).trim(),
      messageText: followupString(json['message_text']),
      aiMessage: followupString(json['ai_message']),
      aiBrief: followupString(json['ai_brief']),
      templateText: followupString(json['template_text']),
      step: followupString(json['step']).trim(),
      channel:
          channelRaw == 'call' ? FollowupChannel.call : FollowupChannel.message,
      dueAtRaw: followupString(json['due_at']).trim(),
      isOverdue: followupBool(json['is_overdue']),
      customerType: followupString(json['customer_type']).trim(),
      valueBand: followupString(json['value_band']).trim(),
      orderValue: followupDouble(json['order_value']),
      invoice: followupString(json['invoice']),
      wooOrderId: followupInt(json['woo_order_id']),
      lifetimeOrders: followupInt(json['lifetime_orders']),
      customerSegment: _nullableString(json['customer_segment']),
      rfmIsRegular: followupBool(json['rfm_is_regular']),
      territory: followupString(json['territory']),
      reason: followupString(json['reason']).trim(),
      status: followupString(json['status']).trim(),
      reached: followupString(json['reached']).trim(),
      outcome: followupString(json['outcome']).trim(),
      notes: followupString(json['notes']),
      apologyCode: _nullableString(json['apology_code']),
      escalationTask: _nullableString(json['escalation_task']),
    );
  }

  /// A copy with the message / AI fields replaced (everything else is kept).
  FollowupRow copyWithAi({
    String? messageText,
    String? aiMessage,
    String? aiBrief,
  }) =>
      FollowupRow(
        name: name,
        customer: customer,
        customerName: customerName,
        phone: phone,
        whatsappMsisdn: whatsappMsisdn,
        messageText: messageText ?? this.messageText,
        aiMessage: aiMessage ?? this.aiMessage,
        aiBrief: aiBrief ?? this.aiBrief,
        templateText: templateText,
        step: step,
        channel: channel,
        dueAtRaw: dueAtRaw,
        isOverdue: isOverdue,
        customerType: customerType,
        valueBand: valueBand,
        orderValue: orderValue,
        invoice: invoice,
        wooOrderId: wooOrderId,
        lifetimeOrders: lifetimeOrders,
        customerSegment: customerSegment,
        rfmIsRegular: rfmIsRegular,
        territory: territory,
        reason: reason,
        status: status,
        reached: reached,
        outcome: outcome,
        notes: notes,
        apologyCode: apologyCode,
        escalationTask: escalationTask,
      );

  bool get isCall => channel == FollowupChannel.call;
  bool get isRepeat => customerType.toLowerCase() == 'repeat';
  bool get isNew => customerType.toLowerCase() == 'new';
  bool get isHighValue => valueBand.toLowerCase() == 'high';

  /// The customer name, or the customer id when the name is missing.
  String get displayName =>
      customerName.trim().isNotEmpty ? customerName.trim() : customer;

  /// [dueAtRaw] parsed as local wall-clock time, or null.
  DateTime? get dueAt =>
      dueAtRaw.isEmpty ? null : DateTime.tryParse(dueAtRaw.replaceFirst(' ', 'T'));

  /// The day number of a `dayN` step (`day7` → 7); null for `3h` or unknown.
  int? get stepDay {
    final match = RegExp(r'^day(\d+)$').firstMatch(step.toLowerCase());
    return match == null ? null : int.tryParse(match.group(1)!);
  }
}

/// `get_followups_today` as a whole.
class FollowupsToday {
  final FollowupSummary summary;
  final List<FollowupRow> rows;

  const FollowupsToday({
    this.summary = const FollowupSummary(),
    this.rows = const <FollowupRow>[],
  });

  factory FollowupsToday.fromJson(dynamic json) {
    if (json is! Map) return const FollowupsToday();
    // The shipped backend sends `items`; `rows` was the draft contract.
    final rawRows = json['items'] ?? json['rows'];
    final rows = rawRows is List
        ? rawRows
            .whereType<Map>()
            .map((e) => FollowupRow.fromJson(Map<String, dynamic>.from(e)))
            .where((r) => r.name.isNotEmpty)
            .toList(growable: false)
        : const <FollowupRow>[];
    return FollowupsToday(
      summary: FollowupSummary.fromJson(json['summary']),
      rows: rows,
    );
  }

  List<FollowupRow> get overdueRows =>
      rows.where((r) => r.isOverdue).toList(growable: false);
  List<FollowupRow> get todayRows =>
      rows.where((r) => !r.isOverdue).toList(growable: false);

  /// This list with the touch [name] replaced by [update] applied to it.
  FollowupsToday updating(
    String name,
    FollowupRow Function(FollowupRow) update,
  ) =>
      FollowupsToday(
        summary: summary,
        rows: List.unmodifiable([
          for (final r in rows) r.name == name ? update(r) : r,
        ]),
      );

  /// This list with the touch [name] removed and the summary adjusted.
  FollowupsToday without(String name) {
    FollowupRow? removed;
    final remaining = <FollowupRow>[];
    for (final r in rows) {
      if (removed == null && r.name == name) {
        removed = r;
      } else {
        remaining.add(r);
      }
    }
    if (removed == null) return this;
    return FollowupsToday(
      summary: summary.without(removed),
      rows: List.unmodifiable(remaining),
    );
  }
}

/// What `log_touch` / `skip_touch` answer: the updated item, which carries
/// `apology_code` and `escalation_task` inside it.
class FollowupLogResult {
  final FollowupRow? row;
  final String? apologyCode;
  final String? escalationTask;

  const FollowupLogResult({this.row, this.apologyCode, this.escalationTask});

  factory FollowupLogResult.fromJson(dynamic json) {
    if (json is! Map) return const FollowupLogResult();
    final map = Map<String, dynamic>.from(json);
    // The row may come flat (row fields beside the extras) or nested.
    final nested = map['row'];
    final rowJson = nested is Map ? Map<String, dynamic>.from(nested) : map;
    final row = followupString(rowJson['name']).isEmpty
        ? null
        : FollowupRow.fromJson(rowJson);
    return FollowupLogResult(
      row: row,
      apologyCode: _nullableString(map['apology_code']) ?? row?.apologyCode,
      escalationTask:
          _nullableString(map['escalation_task']) ?? row?.escalationTask,
    );
  }
}

/// `get_followup_stats`.
class FollowupStats {
  final String fromDate;
  final String toDate;

  /// Touches in the range.
  final int total;
  final Map<String, int> byStatus;
  final Map<String, int> byOutcome;
  final int callsTotal;
  final int callsReached;

  /// As sent; may be a 0–1 fraction or a 0–100 percentage.
  final double reachRate;

  /// Customers who ordered again after a touch.
  final int reordered;
  final int touchedCustomers;

  /// As sent; may be a 0–1 fraction or a 0–100 percentage.
  final double reorderRate;

  const FollowupStats({
    this.fromDate = '',
    this.toDate = '',
    this.total = 0,
    this.byStatus = const <String, int>{},
    this.byOutcome = const <String, int>{},
    this.callsTotal = 0,
    this.callsReached = 0,
    this.reachRate = 0,
    this.reordered = 0,
    this.touchedCustomers = 0,
    this.reorderRate = 0,
  });

  factory FollowupStats.fromJson(dynamic json) {
    if (json is! Map) return const FollowupStats();
    // Shipped names first (`calls_done`, `reordered_customers`), the draft
    // contract's (`calls_total`, `reordered`) as fallbacks.
    return FollowupStats(
      fromDate: followupString(json['from_date']),
      toDate: followupString(json['to_date']),
      total: followupInt(json['total']),
      byStatus: _countMap(json['by_status']),
      byOutcome: _countMap(json['by_outcome']),
      callsTotal: followupInt(json['calls_done'] ?? json['calls_total']),
      callsReached: followupInt(json['calls_reached']),
      reachRate: followupDouble(json['reach_rate']),
      reordered: followupInt(json['reordered_customers'] ?? json['reordered']),
      touchedCustomers: followupInt(json['touched_customers']),
      reorderRate: followupDouble(json['reorder_rate']),
    );
  }

  /// Reach rate as a 0–100 percentage, whichever scale the server used.
  double get reachPercent {
    if (reachRate <= 0) {
      return callsTotal > 0 ? callsReached * 100 / callsTotal : 0;
    }
    return reachRate <= 1 ? reachRate * 100 : reachRate;
  }

  /// Reorder rate as a 0–100 percentage, whichever scale the server used.
  double get reorderPercent {
    if (reorderRate <= 0) {
      return touchedCustomers > 0 ? reordered * 100 / touchedCustomers : 0;
    }
    return reorderRate <= 1 ? reorderRate * 100 : reorderRate;
  }
}

/// `draft_followup_message`: the (possibly cached) WhatsApp text.
class FollowupDraftResult {
  final String name;
  final String messageText;

  /// `claude` | `template`.
  final String source;
  final bool cached;
  final String error;

  const FollowupDraftResult({
    this.name = '',
    this.messageText = '',
    this.source = 'template',
    this.cached = false,
    this.error = '',
  });

  factory FollowupDraftResult.fromJson(dynamic json) {
    if (json is! Map) return const FollowupDraftResult();
    return FollowupDraftResult(
      name: followupString(json['name']),
      messageText: followupString(json['message_text']),
      source: followupString(json['source'], fallback: 'template').trim(),
      cached: followupBool(json['cached']),
      error: followupString(json['error']),
    );
  }

  bool get isClaude => source.toLowerCase() == 'claude';
}

/// `get_call_brief`: the (possibly cached) pre-call brief.
class FollowupBriefResult {
  final String name;
  final String brief;

  /// `claude` | `template`.
  final String source;
  final bool cached;
  final String error;

  const FollowupBriefResult({
    this.name = '',
    this.brief = '',
    this.source = 'template',
    this.cached = false,
    this.error = '',
  });

  factory FollowupBriefResult.fromJson(dynamic json) {
    if (json is! Map) return const FollowupBriefResult();
    return FollowupBriefResult(
      name: followupString(json['name']),
      brief: followupString(json['brief']),
      source: followupString(json['source'], fallback: 'template').trim(),
      cached: followupBool(json['cached']),
      error: followupString(json['error']),
    );
  }

  bool get isClaude => source.toLowerCase() == 'claude';
}

/// One inbound WhatsApp message a customer sent after a follow-up.
class FollowupSentReply {
  /// `YYYY-MM-DD HH:MM:SS`.
  final String at;
  final String text;

  /// `text`, `image`, `audio`, `button`, ... as Meta names it.
  final String type;

  /// The customer asked to stop receiving messages.
  final bool isStop;

  const FollowupSentReply({
    this.at = '',
    this.text = '',
    this.type = 'text',
    this.isStop = false,
  });

  factory FollowupSentReply.fromJson(Map json) => FollowupSentReply(
        at: followupString(json['at']),
        text: followupString(json['text']),
        type:
            followupString(json['type'], fallback: 'text').trim().toLowerCase(),
        isStop: followupBool(json['is_stop']),
      );

  /// The reply carries written text that can be shown as is.
  bool get hasText => text.trim().isNotEmpty;
}

/// A retail invoice the customer placed after a follow-up message.
class FollowupSentOrder {
  final String invoice;
  final String at;
  final double grandTotal;
  final String wooOrderId;

  /// This invoice redeemed the follow-up code.
  final bool usedCode;

  const FollowupSentOrder({
    required this.invoice,
    this.at = '',
    this.grandTotal = 0,
    this.wooOrderId = '',
    this.usedCode = false,
  });

  factory FollowupSentOrder.fromJson(Map json) => FollowupSentOrder(
        invoice: followupString(json['invoice']),
        at: followupString(json['at']),
        grandTotal: followupDouble(json['grand_total']),
        wooOrderId: followupString(json['woo_order_id']),
        usedCode: followupBool(json['used_code']),
      );

  /// What the user knows the order as: the website order number when there is
  /// one, the invoice name otherwise.
  String get displayId => wooOrderId.isNotEmpty ? wooOrderId : invoice;
}

List<T> _mapList<T>(dynamic value, T Function(Map) parse) => [
      if (value is List)
        for (final v in value)
          if (v is Map) parse(v),
    ];

/// One template message the follow-up sender sent (`get_sent_report` item).
class FollowupSentItem {
  final String name;
  final String customer;
  final String customerName;
  final String phone;
  final String step;
  final String sentAt;
  final String offerCode;
  final String orderNo;

  /// `sent` / `delivered` / `read` / `failed`, as Meta last reported it.
  final String waStatus;
  final String error;
  final bool replied;

  /// The first retail invoice within 30 days of the send, or empty.
  final String reorderInvoice;

  /// Tier of the offer code: vip / loyal / repeat / one_big / one, or empty.
  final String tier;

  /// `used` / `expired` / `unused`, or empty when the message had no code.
  final String codeStatus;
  final double codeDiscount;
  final String codeInvoice;

  /// The first replies (at most 5, oldest first) and how many there were.
  final List<FollowupSentReply> replies;
  final int replyCount;

  /// The first orders within 30 days (at most 5, oldest first), and the sum of
  /// all of them.
  final List<FollowupSentOrder> orders;
  final double reorderTotal;

  const FollowupSentItem({
    required this.name,
    this.customer = '',
    this.customerName = '',
    this.phone = '',
    this.step = '',
    this.sentAt = '',
    this.offerCode = '',
    this.orderNo = '',
    this.waStatus = 'sent',
    this.error = '',
    this.replied = false,
    this.reorderInvoice = '',
    this.tier = '',
    this.codeStatus = '',
    this.codeDiscount = 0,
    this.codeInvoice = '',
    this.replies = const <FollowupSentReply>[],
    this.replyCount = 0,
    this.orders = const <FollowupSentOrder>[],
    this.reorderTotal = 0,
  });

  factory FollowupSentItem.fromJson(Map json) {
    final replies = _mapList(json['replies'], FollowupSentReply.fromJson);
    final replyCount = followupInt(json['reply_count'], fallback: replies.length);
    return FollowupSentItem(
      name: followupString(json['name']),
      customer: followupString(json['customer']),
      customerName: followupString(json['customer_name']),
      phone: followupString(json['phone']),
      step: followupString(json['step']),
      sentAt: followupString(json['sent_at']),
      offerCode: followupString(json['offer_code']),
      orderNo: followupString(json['order_no']),
      waStatus: followupString(json['wa_status'], fallback: 'sent'),
      error: followupString(json['error']),
      replied: followupBool(json['replied']) ||
          replies.isNotEmpty ||
          replyCount > 0,
      reorderInvoice: followupString(json['reorder_invoice']),
      tier: followupString(json['tier']),
      codeStatus: followupString(json['code_status']),
      codeDiscount: followupDouble(json['code_discount']),
      codeInvoice: followupString(json['code_invoice']),
      replies: replies,
      replyCount: replyCount,
      orders: _mapList(json['orders'], FollowupSentOrder.fromJson),
      reorderTotal: followupDouble(json['reorder_total']),
    );
  }

  bool get reordered => reorderInvoice.isNotEmpty || orders.isNotEmpty;
  bool get hasCode => offerCode.isNotEmpty;
  bool get codeUsed => codeStatus == 'used';
}

/// Cost of the campaign against what it brought (`get_sent_report.money`).
class FollowupMoney {
  final String currency;
  final double messageCostEach;
  final int billableMessages;
  final double messagesCost;
  final double discountCost;
  final double totalCost;

  /// Distinct orders (one invoice can follow two messages).
  final int orders;
  final double revenue;
  final int ordersWithCode;
  final double revenueWithCode;
  final double net;

  /// Revenue / total cost; null when nothing was spent.
  final double? roi;
  final double? costPerOrder;

  const FollowupMoney({
    this.currency = 'EGP',
    this.messageCostEach = 0,
    this.billableMessages = 0,
    this.messagesCost = 0,
    this.discountCost = 0,
    this.totalCost = 0,
    this.orders = 0,
    this.revenue = 0,
    this.ordersWithCode = 0,
    this.revenueWithCode = 0,
    this.net = 0,
    this.roi,
    this.costPerOrder,
  });

  factory FollowupMoney.fromJson(Map json) => FollowupMoney(
        currency: followupString(json['currency'], fallback: 'EGP'),
        messageCostEach: followupDouble(json['message_cost_each']),
        billableMessages: followupInt(json['billable_messages']),
        messagesCost: followupDouble(json['messages_cost']),
        discountCost: followupDouble(json['discount_cost']),
        totalCost: followupDouble(json['total_cost']),
        orders: followupInt(json['orders']),
        revenue: followupDouble(json['revenue']),
        ordersWithCode: followupInt(json['orders_with_code']),
        revenueWithCode: followupDouble(json['revenue_with_code']),
        net: followupDouble(json['net']),
        roi: json['roi'] == null ? null : followupDouble(json['roi']),
        costPerOrder: json['cost_per_order'] == null
            ? null
            : followupDouble(json['cost_per_order']),
      );
}

/// Distinct codes the messages carried and what became of them.
class FollowupCodes {
  final int issued;
  final int used;
  final int unused;
  final int expired;

  const FollowupCodes({
    this.issued = 0,
    this.used = 0,
    this.unused = 0,
    this.expired = 0,
  });

  factory FollowupCodes.fromJson(Map json) => FollowupCodes(
        issued: followupInt(json['issued']),
        used: followupInt(json['used']),
        unused: followupInt(json['unused']),
        expired: followupInt(json['expired']),
      );
}

/// `get_sent_report`: what the automatic WhatsApp follow-ups sent, and what
/// came of it.
class FollowupSentReport {
  final String fromDate;
  final String toDate;

  /// sent / delivered / read / failed / replied / reordered.
  final Map<String, int> totals;

  /// step -> {sent, delivered, read, reordered}.
  final Map<String, Map<String, int>> byStep;

  /// `YYYY-MM-DD` -> messages sent that day.
  final Map<String, int> byDay;

  /// Cancel reason -> touches cancelled in the range.
  final Map<String, int> cancelled;
  final int optedOutCustomers;

  /// Sends Meta refused, now waiting on the staff worklist.
  final int refusedWaitingForStaff;
  final List<FollowupSentItem> items;

  /// Messages in the range; [items] is capped, so this can be larger.
  final int itemsTotal;

  /// Null when the server predates the cost report.
  final FollowupMoney? money;

  /// Null when the server predates the code report.
  final FollowupCodes? codes;

  /// Distinct customers messaged in the range.
  final int customers;

  const FollowupSentReport({
    this.fromDate = '',
    this.toDate = '',
    this.totals = const <String, int>{},
    this.byStep = const <String, Map<String, int>>{},
    this.byDay = const <String, int>{},
    this.cancelled = const <String, int>{},
    this.optedOutCustomers = 0,
    this.refusedWaitingForStaff = 0,
    this.items = const <FollowupSentItem>[],
    this.itemsTotal = 0,
    this.money,
    this.codes,
    this.customers = 0,
  });

  int total(String key) => totals[key] ?? 0;

  /// Messages the server counted, never fewer than the ones it sent us.
  int get messageCount => itemsTotal > items.length ? itemsTotal : items.length;

  /// Some messages exist that [items] does not carry.
  bool get itemsTruncated => itemsTotal > items.length;

  factory FollowupSentReport.fromJson(dynamic json) {
    if (json is! Map) return const FollowupSentReport();
    final steps = json['by_step'];
    final items = _mapList(json['items'], FollowupSentItem.fromJson);
    final money = json['money'];
    final codes = json['codes'];
    return FollowupSentReport(
      fromDate: followupString(json['from_date']),
      toDate: followupString(json['to_date']),
      totals: _countMap(json['totals']),
      byStep: {
        if (steps is Map)
          for (final e in steps.entries) e.key.toString(): _countMap(e.value),
      },
      byDay: _countMap(json['by_day']),
      cancelled: _countMap(json['cancelled']),
      optedOutCustomers: followupInt(json['opted_out_customers']),
      refusedWaitingForStaff: followupInt(json['refused_waiting_for_staff']),
      items: items,
      itemsTotal: followupInt(json['items_total'], fallback: items.length),
      money: money is Map ? FollowupMoney.fromJson(money) : null,
      codes: codes is Map ? FollowupCodes.fromJson(codes) : null,
      customers: followupInt(json['customers']),
    );
  }
}
