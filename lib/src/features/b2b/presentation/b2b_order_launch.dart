import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../data/models/b2b_models.dart';

/// Navigates into the existing POS cart flow with a B2B [binding] applied:
/// the returned customer is preselected and the order purpose / price list are
/// applied via the matching commercial policy. The order is then placed through
/// the SAME invoice-creation path so it lands on the dispatch Kanban.
void launchB2bOrderInPos(
  BuildContext context, {
  required OrderBinding binding,
  String? customerName,
  String? mobileNo,
}) {
  context.push(
    AppRoutes.pos,
    extra: <String, dynamic>{
      'mode': 'b2b_order',
      'customer': binding.customer,
      'order_purpose': binding.orderPurpose,
      if (binding.priceList != null) 'price_list': binding.priceList,
      if (customerName != null) 'customer_name': customerName,
      if (mobileNo != null) 'mobile_no': mobileNo,
    },
  );
}
