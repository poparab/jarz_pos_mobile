import 'package:flutter/widgets.dart';

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