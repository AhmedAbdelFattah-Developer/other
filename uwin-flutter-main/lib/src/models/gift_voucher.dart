import 'package:uwin_flutter/src/models/voucher.dart';

class GiftVoucher {
  GiftVoucher({
    this.amount,
    this.createdAt,
    this.expiredAt,
    this.id,
    this.name,
    this.shopId,
    this.shopName,
    this.uid,
    this.used,
    this.photoPath,
    this.noScan,
  });
  final int amount;
  final int createdAt;
  final int expiredAt;
  final String id;
  final String name;
  final String shopId;
  final String shopName;
  final String uid;
  final bool used;
  final String photoPath;
  final bool noScan;

  GiftVoucher.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        amount = data['amount'],
        createdAt = data['createdAt'],
        expiredAt = data['expiredAt'],
        name = data['name'],
        shopId = data['shopId'],
        shopName = data['shopName'] ?? data['shopId'],
        uid = data['uid'],
        used = data['used'],
        photoPath = data['photoPath'] ?? '',
        noScan = data['noScan'] ?? false;

  GiftVoucher.fromProductMap(Map<String, dynamic> data)
      : id = data['id'],
        amount =
            data['price'] is double ? data['price'].toInt() : data['price'],
        createdAt = DateTime.now().millisecondsSinceEpoch,
        expiredAt =
            DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch,
        name = data['name'],
        shopId = data['shopId'],
        shopName = data['shopName'] ?? data['shopId'],
        uid = data['uid'],
        used = data['used'],
        photoPath = data['photoPath'] ?? '',
        noScan = data['noScan'] ?? false;

  bool isValid({int now}) {
    if (now == null) {
      now = DateTime.now().millisecondsSinceEpoch;
    }

    return expiredAt > now && used == false;
  }

  bool get hasPhotoPath => photoPath.isNotEmpty;

  Voucher toVoucher() => Voucher(
        amount: amount,
        shopName: shopName,
        useVoucherCode: false,
        shopId: shopId,
        qtyAvailable: -1,
        photoPath: photoPath,
        name: name,
        id: id,
        gift: true,
        expiredAtUnix: expiredAt,
      );
}
