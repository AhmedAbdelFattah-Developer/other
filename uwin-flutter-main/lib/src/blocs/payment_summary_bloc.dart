import 'dart:async';

import 'package:rxdart/subjects.dart';
import 'package:uwin_flutter/src/models/sales_order.dart';
import 'package:uwin_flutter/src/repositories/payment_repository.dart';
import 'package:uwin_flutter/src/repositories/sales_order_repository.dart';

class PaymentSummaryBloc {
  PaymentSummaryBloc({this.paymentRepo, this.soRepo});

  final PaymentRepository paymentRepo;
  final SalesOrderRepository soRepo;

  final _paymentUrl = BehaviorSubject<String>();

  Stream<String> get paymentUrl => _paymentUrl.stream;

  // Close stream when payment is completed
  Stream<String> paymentState(String salesOrderId) =>
      soRepo.fetch(salesOrderId).transform(
        StreamTransformer.fromHandlers(handleData: (so, sink) {
          final ps = so.paymentState;
          sink.add(ps);
          if (ps == 'completed') {
            sink.close();
          }
        }),
      );

  void init(SalesOrder so) async {
    _paymentUrl.sink.add(null);

    try {
      final session = await paymentRepo.create(so.id);
      _paymentUrl.sink.add(session.paymentUrl);
    } catch (err) {
      print('[payment_summary_bloc] Could not create payment');
      print(err);
      _paymentUrl.sink.addError('Could not create payment session');
    }
  }

  dispose() {
    _paymentUrl.close();
  }

  Future<void> forceComplete(SalesOrder so) {
    return paymentRepo.forceComplete(so.id);
  }
}
