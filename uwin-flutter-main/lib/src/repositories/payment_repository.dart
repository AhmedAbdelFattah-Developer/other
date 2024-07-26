import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/models/payment_session.dart';

const _createSessionEndpoint =
    'https://us-central1-uwin-201010.cloudfunctions.net/mcbPayment/sales-orders/:salesOrderId/create-checkout-session';

class PaymentRepository {
  const PaymentRepository();

  Future<PaymentSession> create(String salesOrderId) async {
    final client = http.Client();
    try {
      final url = _createSessionEndpoint.replaceFirst(
        ':salesOrderId',
        salesOrderId,
      );

      final res = await client.post(Uri.parse(url));

      if (res.statusCode != 200) {
        throw StateError(
            'Could not connect to uWin server. Error code: ${res.statusCode}');
      }

      return PaymentSession.fromMap(
          salesOrderId, json.decode(utf8.decode(res.bodyBytes)));
    } finally {
      client.close();
    }
  }

  Future<void> forceComplete(String id) async {
    final client = http.Client();
    try {
      final url =
          'https://us-central1-uwin-201010.cloudfunctions.net/mcbPayment/sales-orders/$id/dev-complete';
      final res = await client.post(Uri.parse(url));

      if (res.statusCode != 204) {
        throw StateError(
            'Could not connect to uWin server. Error code: ${res.statusCode}');
      }
    } finally {
      client.close();
    }
  }
}
