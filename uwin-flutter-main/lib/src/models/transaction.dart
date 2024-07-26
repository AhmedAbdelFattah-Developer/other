import 'package:flutter/foundation.dart';

class Transaction {
  final double transTotal;
  final double transDiscount;
  final bool discounted;
  final double discountAmount;
  final List<TransactionFlashSale> flashsales;
  final List<String> vouchers;
  final List<String> giftVouchers;
  final List<String> coupons;
  final String geolocation;

  Transaction({
    @required this.coupons,
    @required this.flashsales,
    @required this.transDiscount,
    @required this.transTotal,
    @required this.vouchers,
    @required this.discountAmount,
    @required this.discounted,
    @required this.giftVouchers,
    this.geolocation,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'flashsales': flashsales.map((f) => f.toMap()).toList(),
      'vouchers': vouchers,
      'giftVouchers': giftVouchers,
      'coupons': coupons,
      'transDiscount': transDiscount,
      'transTotal': transTotal,
      'discountAmount': discountAmount,
      'discounted': discounted,
      'geolocation': geolocation,
    };
  }
}

class TransactionFlashSale {
  final String id;
  final int remainingNbSales;

  TransactionFlashSale({
    @required this.id,
    @required this.remainingNbSales,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'remainingNbSales': remainingNbSales,
    };
  }
}

class TransactionServer {
  final double transTotal;
  final double transDiscount;
  final List<TransactionFlashSale> flashsales;
  final List<TransactionServerVoucher> vouchers;
  final List<TransactionServerCoupon> coupons;

  TransactionServer.fromTransaction(Transaction trans)
      : transDiscount = trans.transDiscount,
        transTotal = trans.transTotal,
        flashsales = trans.flashsales,
        coupons = trans.coupons
            .map((id) => TransactionServerCoupon(id: id, usedDate: 1))
            .toList(),
        vouchers = trans.vouchers
            .map((id) => TransactionServerVoucher(id: id, usedDate: 1))
            .toList();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '@type': 'UserShopDTO',
      'transTotal': transTotal,
      'transDiscount': transDiscount,
      'flashSellList': flashsales.map((obj) => obj.toMap()).toList(),
      'voucherList': vouchers.map((obj) => obj.toMap()).toList(),
      'couponList': coupons.map((obj) => obj.toMap()).toList(),
    };
  }
}

class TransactionServerVoucher {
  final String id;
  final int usedDate;

  const TransactionServerVoucher({
    @required this.id,
    @required this.usedDate,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'usedDate': usedDate};
  }
}

class TransactionServerCoupon {
  final String id;
  final int usedDate;

  const TransactionServerCoupon({
    @required this.id,
    @required this.usedDate,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'usedDate': usedDate};
  }
}
