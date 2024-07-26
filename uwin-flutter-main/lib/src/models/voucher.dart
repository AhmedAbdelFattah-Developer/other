import 'package:uwin_flutter/src/models/item.dart';

import 'shop.dart';

class Voucher {
  final String id;
  final int expiredAtUnix;
  final String name;
  final String shopId;
  final String shopName;
  final String photoPath;
  final int amount;
  final bool gift;
  final int qtyAvailable;
  final bool useVoucherCode;

  Voucher(
      {this.id,
      this.name,
      this.shopId,
      this.shopName,
      this.expiredAtUnix,
      this.photoPath,
      this.amount,
      this.qtyAvailable,
      this.gift = false,
      this.useVoucherCode});

  Voucher.fromApi(Map<String, dynamic> data)
      : id = data['id'],
        expiredAtUnix = data['validityDate'],
        name = data['name'],
        amount = data['voucherValue'],
        photoPath = data['photoPath'],
        shopId = data['idShop'],
        shopName = data['nameShop'] ?? data['shopName'] ?? '',
        qtyAvailable = data['qtyAvailable'],
        useVoucherCode = data['useVoucherCode'] ?? false,
        gift = false;

  Voucher.fromFirebase(Shop shop, Map<String, dynamic> data)
      : id = data['id'],
        expiredAtUnix =
            DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch,
        name = data['name'],
        amount = data['amount'] ?? data['price']?.round(),
        photoPath = data['photoPath'] ??
            (shop.photoPath.length > 0 ? shop.photoPath.first : null),
        shopId = shop.id,
        shopName = shop.name,
        qtyAvailable = 0,
        useVoucherCode = false,
        gift = true;

  Voucher.firestoreGiftVoucher(Map<String, dynamic> data)
      : id = data['id'],
        expiredAtUnix = DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
            .add(Duration(days: 30))
            .millisecondsSinceEpoch,
        name = data['name'],
        amount = data['amount'],
        photoPath = data['photoPath'],
        shopId = data['shopId'],
        shopName = data['shopName'],
        qtyAvailable = 0,
        useVoucherCode = data['useVoucherCode'] ?? false,
        gift = true;

  DateTime get expiredAt => DateTime.fromMillisecondsSinceEpoch(expiredAtUnix);

  Item toItem() {
    return Item(
      id: id,
      description: name,
      name: name,
      photoPath: photoPath,
      price: amount.toDouble(),
      shopId: shopId,
    );
  }
}

class VoucherCode {
  final String voucherId;
  final String code;

  VoucherCode({this.code, this.voucherId});

  VoucherCode.fromMap(Map<String, dynamic> data)
      : voucherId = data['voucherId'],
        code = data['code'];
}
