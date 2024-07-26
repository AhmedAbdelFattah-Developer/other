const _paymentEndpoint =
    'https://us-central1-uwin-201010.cloudfunctions.net/mcbPayment/sales-orders/:salesOrderId/payment-gateway/:sessionId';

class PaymentSession {
  final String id;
  final String salesOrderId;
  final String merchant;
  final String result;
  final String updateStatus;
  final String version;
  final String successIndicator;

  const PaymentSession({
    this.id,
    this.merchant,
    this.result,
    this.successIndicator,
    this.updateStatus,
    this.version,
    this.salesOrderId,
  });

  PaymentSession.fromMap(this.salesOrderId, Map<String, dynamic> data)
      : id = data['session.id'],
        merchant = data['merchant'],
        result = data['result'],
        updateStatus = data['session.updateStatus'],
        version = data['session.version'],
        successIndicator = data['successIndicator'];

  String get paymentUrl => _paymentEndpoint
      .replaceFirst(':salesOrderId', salesOrderId)
      .replaceFirst(':sessionId', id);
}
