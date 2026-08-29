import 'package:flutter/widgets.dart';

import '../../features/pos/order_alert/web_push_registration_result.dart';
import 'localization_extensions.dart';

String localizedStatusLabel(BuildContext context, String? rawStatus) {
  final status = rawStatus?.trim() ?? '';
  switch (status.toLowerCase()) {
    case 'created':
      return context.l10n.statusCreated;
    case 'out for delivery':
      return context.l10n.statusOutForDelivery;
    case 'completed':
      return context.l10n.statusCompleted;
    case 'delivered':
      return context.l10n.statusDelivered;
    case 'return':
      return context.l10n.statusReturn;
    // Terminal kanban state for a fully returned order — distinct from the
    // courier's "Returned to Sender" below.
    case 'returned':
      return context.l10n.statusReturned;
    case 'returned to sender':
      return context.l10n.statusReturnedToSender;
    case 'paid':
      return context.l10n.statusPaid;
    case 'unpaid':
      return context.l10n.statusUnpaid;
    case 'overdue':
      return context.l10n.statusOverdue;
    case 'cancelled':
      return context.l10n.statusCancelled;
    case 'confirmed':
      return context.l10n.statusConfirmed;
    case 'unconfirmed':
      return context.l10n.statusUnconfirmed;
    case 'pending':
      return context.l10n.statusPending;
    case 'pending approval':
      return context.l10n.statusPendingApproval;
    case 'approved':
      return context.l10n.statusApproved;
    case 'rejected':
      return context.l10n.statusRejected;
    case 'draft':
      return context.l10n.statusDraft;
    // A payment receipt whose collected method was edited after upload.
    case 'changed':
      return context.l10n.statusChanged;
    // Courier and sales-partner transactions.
    case 'settled':
      return context.l10n.statusSettled;
    case 'unsettled':
      return context.l10n.statusUnsettled;
    case 'accepted':
      return context.l10n.statusAccepted;
    case 'active':
      return context.l10n.statusActive;
    case 'paused':
      return context.l10n.statusPaused;
    case 'ended':
      return context.l10n.statusEnded;
    case 'closed':
      return context.l10n.statusClosed;
    case 'in progress':
      return context.l10n.statusInProgress;
    default:
      return status.isEmpty ? context.l10n.commonNotSpecified : status;
  }
}

String localizedPaymentMethodLabel(BuildContext context, String? rawMethod) {
  final method = rawMethod?.trim() ?? '';
  switch (method.toLowerCase()) {
    case 'cash':
      return context.l10n.paymentMethodCash;
    case 'card':
    case 'credit card':
      return context.l10n.paymentMethodCard;
    case 'instapay':
      return context.l10n.paymentMethodInstapay;
    case 'mobile wallet':
    case 'wallet':
      return context.l10n.paymentMethodMobileWallet;
    case 'settle later':
      return context.l10n.paymentMethodSettleLater;
    // The backend reports "Online" for a delivery-partner order the partner
    // collected for us: real, but not one of our own tills or ledgers.
    case 'online':
      return context.l10n.paymentMethodOnline;
    default:
      return method.isEmpty ? context.l10n.commonNotSpecified : method;
  }
}

String localizedPartyTypeLabel(BuildContext context, String? rawType) {
  final type = rawType?.trim() ?? '';
  switch (type.toLowerCase()) {
    case 'employee':
      return context.l10n.kanbanEmployee;
    case 'supplier':
      return context.l10n.kanbanSupplier;
    case 'sales partner':
      return context.l10n.salesPartnerTitle;
    case 'customer':
      return context.l10n.commonCustomerLabel;
    default:
      return type.isEmpty ? context.l10n.commonNotSpecified : type;
  }
}
/// Print-order lifecycle for a customer label batch, as ERPNext stores it.
String localizedLabelPrintStatus(BuildContext context, String? rawStatus) {
  final status = rawStatus?.trim() ?? '';
  switch (status.toLowerCase()) {
    case 'requested':
      return context.l10n.labelPrintStatusRequested;
    case 'printing':
      return context.l10n.labelPrintStatusPrinting;
    case 'ready':
      return context.l10n.labelPrintStatusReady;
    case 'received':
      return context.l10n.labelPrintStatusReceived;
    case 'cancelled':
      return context.l10n.labelPrintStatusCancelled;
    default:
      return status.isEmpty ? context.l10n.commonNotSpecified : status;
  }
}

/// Why a label's stock moved, as ERPNext stores it.
String localizedLabelMovementType(BuildContext context, String? rawType) {
  final type = rawType?.trim() ?? '';
  switch (type.toLowerCase()) {
    case 'consumed':
      return context.l10n.labelMovementConsumed;
    case 'print received':
      return context.l10n.labelMovementPrintReceived;
    case 'scrapped':
      return context.l10n.labelMovementScrapped;
    case 'adjustment':
      return context.l10n.labelMovementAdjustment;
    default:
      return type.isEmpty ? context.l10n.commonNotSpecified : type;
  }
}

/// A lead's B2B pipeline stage, as ERPNext stores it in `custom_b2b_stage`.
/// The raw value stays the source of truth everywhere except the screen.
String localizedLeadStage(BuildContext context, String? rawStage) {
  final stage = rawStage?.trim() ?? '';
  switch (stage.toLowerCase()) {
    case 'lead':
      return context.l10n.b2bStageLead;
    case 'qualify':
      return context.l10n.b2bStageQualify;
    case 'sample':
      return context.l10n.b2bStageSample;
    case 'approved':
      return context.l10n.b2bStageApproved;
    case 'trial':
      return context.l10n.b2bStageTrial;
    case 'check-up':
      return context.l10n.b2bStageCheckup;
    case 'active':
      return context.l10n.b2bStageActive;
    case 'lost/on-hold':
      return context.l10n.b2bStageLostOnHold;
    default:
      return stage.isEmpty ? context.l10n.commonNotSpecified : stage;
  }
}

/// A journey entry's type, as ERPNext stores it in the Select field.
String localizedJourneyType(BuildContext context, String? rawType) {
  switch ((rawType ?? '').trim().toLowerCase()) {
    case 'visit':
      return context.l10n.journeyTypeVisit;
    case 'call':
      return context.l10n.journeyTypeCall;
    case 'whatsapp':
      return context.l10n.journeyTypeWhatsapp;
    case 'sample drop':
      return context.l10n.journeyTypeSampleDrop;
    case 'meeting':
      return context.l10n.journeyTypeMeeting;
    case 'email':
      return context.l10n.journeyTypeEmail;
    case 'other':
      return context.l10n.journeyTypeOther;
    default:
      // A Select option added in Desk since this release: show it as stored
      // rather than swallowing it.
      return (rawType ?? '').trim();
  }
}

/// A journey entry's outcome, as ERPNext stores it in the Select field.
String localizedJourneyOutcome(BuildContext context, String? rawOutcome) {
  switch ((rawOutcome ?? '').trim().toLowerCase()) {
    case 'interested':
      return context.l10n.journeyOutcomeInterested;
    case 'needs follow-up':
      return context.l10n.journeyOutcomeNeedsFollowUp;
    case 'sample requested':
      return context.l10n.journeyOutcomeSampleRequested;
    case 'order placed':
      return context.l10n.journeyOutcomeOrderPlaced;
    case 'not now':
      return context.l10n.journeyOutcomeNotNow;
    case 'rejected':
      return context.l10n.journeyOutcomeRejected;
    default:
      return (rawOutcome ?? '').trim();
  }
}

/// The user-facing sentence for a web-push registration attempt.
///
/// The service layer runs without a BuildContext (conditional web imports,
/// static helpers), so its `message` stays English for the logs and the
/// status enum is what the screen translates. Only `failed` falls back to the
/// raw message, because that one carries a sanitized error detail worth
/// showing verbatim.
String localizedWebPushMessage(
  BuildContext context,
  WebPushRegistrationStatus status,
  String fallback,
) {
  switch (status) {
    case WebPushRegistrationStatus.disabled:
      return context.l10n.webPushDisabledForEnv;
    case WebPushRegistrationStatus.unsupported:
      return context.l10n.webPushUnsupportedPrompt;
    case WebPushRegistrationStatus.missingConfig:
      return context.l10n.webPushNotConfigured;
    case WebPushRegistrationStatus.permissionRequired:
      return context.l10n.webPushPermissionRequired;
    case WebPushRegistrationStatus.permissionDenied:
      return context.l10n.webPushPermissionDenied;
    case WebPushRegistrationStatus.noToken:
      return context.l10n.webPushNoToken;
    case WebPushRegistrationStatus.tokenReady:
      return context.l10n.webPushTokenReady;
    case WebPushRegistrationStatus.registered:
      return context.l10n.webPushEnabled;
    case WebPushRegistrationStatus.failed:
      return fallback;
  }
}

// ── Server-driven lookup vocabularies ──────────────────────────────────────
//
// Everything below follows one rule: the RAW English value stays the wire
// value and the sort/compare key; only the rendered string is translated. Each
// mapper falls through to the raw text so a Select option added in Desk shows
// up as itself instead of vanishing behind an app release.

/// A Kanban board column, i.e. a `Sales Invoice.custom_sales_invoice_state`
/// option. `Recieved` is the real, misspelt option on the live sites — both
/// spellings map to the same label so a future data fix needs no app release.
String localizedKanbanState(BuildContext context, String? rawState) {
  final state = rawState?.trim() ?? '';
  switch (state.toLowerCase()) {
    case 'recieved':
    case 'received':
      return context.l10n.kanbanStateReceived;
    case 'in progress':
      return context.l10n.kanbanStateInProgress;
    case 'ready':
      return context.l10n.kanbanStateReady;
    default:
      // Out for Delivery / Delivered / Cancelled / Returned already live in
      // the shared status vocabulary, which also handles the empty case.
      return localizedStatusLabel(context, state);
  }
}

/// A preset cancellation reason. The English text is what reaches the server,
/// so only the dropdown label changes here.
String localizedCancelReason(BuildContext context, String? rawReason) {
  final reason = rawReason?.trim() ?? '';
  switch (reason.toLowerCase()) {
    case 'customer requested cancellation':
      return context.l10n.cancelReasonCustomerRequested;
    case 'order created in error / duplicate':
      return context.l10n.cancelReasonCreatedInError;
    case 'inventory unavailable':
      return context.l10n.cancelReasonInventoryUnavailable;
    case 'payment issue':
      return context.l10n.cancelReasonPaymentIssue;
    case 'other':
      return context.l10n.cancelReasonOther;
    default:
      return reason;
  }
}

/// A lead disqualification reason (`Lead.custom_not_suitable_reason`). The list
/// is fetched from the server, so an option added in Desk falls through raw.
String localizedNotSuitableReason(BuildContext context, String? rawReason) {
  final reason = rawReason?.trim() ?? '';
  switch (reason.toLowerCase()) {
    case 'out of business':
      return context.l10n.notSuitableReasonOutOfBusiness;
    case 'wrong category':
      return context.l10n.notSuitableReasonWrongCategory;
    case 'too small':
      return context.l10n.notSuitableReasonTooSmall;
    case 'no contact info':
      return context.l10n.notSuitableReasonNoContactInfo;
    case 'unreachable':
      return context.l10n.notSuitableReasonUnreachable;
    case 'already supplied':
      return context.l10n.notSuitableReasonAlreadySupplied;
    case 'price mismatch':
      return context.l10n.notSuitableReasonPriceMismatch;
    case 'outside delivery area':
      return context.l10n.notSuitableReasonOutsideDeliveryArea;
    case 'duplicate':
      return context.l10n.notSuitableReasonDuplicate;
    case 'not interested':
      return context.l10n.notSuitableReasonNotInterested;
    case 'other':
      return context.l10n.notSuitableReasonOther;
    default:
      return reason;
  }
}

/// Where a lead came from (`Lead.custom_lead_source`).
String localizedLeadSource(BuildContext context, String? rawSource) {
  final source = rawSource?.trim() ?? '';
  switch (source.toLowerCase()) {
    case 'walk in':
      return context.l10n.leadSourceWalkIn;
    case 'reference':
      return context.l10n.leadSourceReference;
    case 'campaign':
      return context.l10n.leadSourceCampaign;
    case 'existing customer':
      return context.l10n.leadSourceExistingCustomer;
    case 'cold call':
      return context.l10n.leadSourceColdCall;
    case 'social media':
      return context.l10n.leadSourceSocialMedia;
    default:
      return source;
  }
}

/// An RFM segment (`Customer.customer_segment`), as the analytics endpoints
/// emit it. The reports also invent "Unclassified" for a customer with no
/// segment yet, so that one is mapped here too.
String localizedCustomerSegment(BuildContext context, String? rawSegment) {
  final segment = rawSegment?.trim() ?? '';
  switch (segment.toLowerCase()) {
    case 'champion':
    case 'champions':
      return context.l10n.customerSegmentChampion;
    case 'loyal':
      return context.l10n.customerSegmentLoyal;
    case 'potential loyalist':
      return context.l10n.customerSegmentPotentialLoyalist;
    case 'new customer':
      return context.l10n.customerSegmentNewCustomer;
    case 'at risk':
      return context.l10n.customerSegmentAtRisk;
    case "can't lose them":
      return context.l10n.customerSegmentCantLoseThem;
    case 'lost':
      return context.l10n.customerSegmentLost;
    case 'one-time':
      return context.l10n.customerSegmentOneTime;
    case 'unclassified':
      return context.l10n.customerSegmentUnclassified;
    default:
      return segment.isEmpty
          ? context.l10n.customerSegmentUnclassified
          : segment;
  }
}

/// An item's sales-velocity trend (`Item.jarz_velocity_trend`).
String localizedVelocityTrend(BuildContext context, String? rawTrend) {
  final trend = rawTrend?.trim() ?? '';
  switch (trend.toLowerCase()) {
    case 'accelerating':
      return context.l10n.velocityTrendAccelerating;
    case 'stable':
      return context.l10n.velocityTrendStable;
    case 'declining':
      return context.l10n.velocityTrendDeclining;
    case 'new item':
      return context.l10n.velocityTrendNewItem;
    case 'no sales':
      return context.l10n.velocityTrendNoSales;
    default:
      return trend;
  }
}

/// A visit plan's or a visit stop's status. One mapper for both: the two Select
/// lists overlap on Draft / Cancelled and never collide on the rest.
String localizedVisitStatus(BuildContext context, String? rawStatus) {
  final status = rawStatus?.trim() ?? '';
  switch (status.toLowerCase()) {
    case 'planned':
      return context.l10n.visitStatusPlanned;
    case 'in progress':
      return context.l10n.visitStatusInProgress;
    case 'visited':
      return context.l10n.visitStatusVisited;
    case 'skipped':
      return context.l10n.visitStatusSkipped;
    default:
      // Draft / Completed / Cancelled are shared vocabulary.
      return localizedStatusLabel(context, status);
  }
}

/// What a sales material is (`Jarz Sales Material.material_type`).
String localizedMaterialType(BuildContext context, String? rawType) {
  final type = rawType?.trim() ?? '';
  switch (type.toLowerCase()) {
    case 'price list':
      return context.l10n.materialTypePriceList;
    case 'product photos':
      return context.l10n.materialTypeProductPhotos;
    case 'catalog':
      return context.l10n.materialTypeCatalog;
    case 'certificate':
      return context.l10n.materialTypeCertificate;
    case 'other':
      return context.l10n.materialTypeOther;
    default:
      return type;
  }
}

/// A B2B pipeline stage abbreviated for a chart axis, where the full label
/// ("Lost/On-hold") would overflow. Arabic stage names are already short, so
/// the Arabic side is simply the normal word.
String localizedB2bStageShort(BuildContext context, String? rawStage) {
  final stage = rawStage?.trim() ?? '';
  switch (stage.toLowerCase()) {
    case 'lead':
      return context.l10n.b2bStageShortLead;
    case 'qualify':
      return context.l10n.b2bStageShortQualify;
    case 'sample':
      return context.l10n.b2bStageShortSample;
    case 'approved':
      return context.l10n.b2bStageShortApproved;
    case 'trial':
      return context.l10n.b2bStageShortTrial;
    case 'check-up':
      return context.l10n.b2bStageShortCheckup;
    case 'active':
      return context.l10n.b2bStageShortActive;
    case 'lost/on-hold':
      return context.l10n.b2bStageShortLostOnHold;
    default:
      return stage;
  }
}
