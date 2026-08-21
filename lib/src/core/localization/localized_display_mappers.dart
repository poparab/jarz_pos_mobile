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
