import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'localization_extensions.dart';

String formatCurrency(
  BuildContext context,
  num amount, {
  String? currencyCode,
}) {
  final locale = context.l10n.localeName;
  final normalizedCurrency = currencyCode?.trim().toUpperCase();
  final effectiveCurrency =
      normalizedCurrency == null || normalizedCurrency.isEmpty
          ? 'EGP'
          : normalizedCurrency;
  final symbol = switch (effectiveCurrency) {
    'EGP' => locale.startsWith('ar') ? 'ج.م' : 'EGP',
    _ => effectiveCurrency,
  };

  return NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: 2,
  ).format(amount);
}

String formatCompactCurrency(
  BuildContext context,
  num amount, {
  String? currencyCode,
}) {
  final locale = context.l10n.localeName;
  final normalizedCurrency = currencyCode?.trim().toUpperCase();
  final effectiveCurrency =
      normalizedCurrency == null || normalizedCurrency.isEmpty
          ? 'EGP'
          : normalizedCurrency;
  final symbol = switch (effectiveCurrency) {
    'EGP' => locale.startsWith('ar') ? 'ج.م' : 'EGP',
    _ => effectiveCurrency,
  };

  return NumberFormat.compactCurrency(
    locale: locale,
    symbol: symbol,
    decimalDigits: 2,
  ).format(amount);
}

String formatDate(
  BuildContext context,
  DateTime date, {
  String pattern = 'MMM d, yyyy',
}) {
  return DateFormat(pattern, context.l10n.localeName).format(date);
}

String formatDateTime(
  BuildContext context,
  DateTime dateTime, {
  String pattern = 'MMM d, yyyy • h:mm a',
}) {
  return DateFormat(pattern, context.l10n.localeName).format(dateTime);
}

String formatDateString(
  BuildContext context,
  String? rawValue, {
  String pattern = 'MMM d, yyyy',
}) {
  final value = rawValue?.trim() ?? '';
  if (value.isEmpty) return context.l10n.commonNotSpecified;

  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return formatDate(context, parsed.toLocal(), pattern: pattern);
}

String formatCount(BuildContext context, num count) {
  return NumberFormat.decimalPattern(context.l10n.localeName).format(count);
}