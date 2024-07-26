import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/models/voucher.dart';

class ShopVoucherRepository {
  Stream<List<Voucher>> fetchAll(Shop shop) {
    return FirebaseFirestore.instance
        .collection('shopVouchers')
        .orderBy('amount')
        .snapshots()
        .map<List<DocumentSnapshot>>((snapshot) => snapshot.docs)
        .map<List<Voucher>>((docs) =>
            docs.map((doc) => Voucher.fromFirebase(shop, doc.data())).toList());
  }

  Stream<List<Voucher>> fetchAllGift(Shop shop) {
    return FirebaseFirestore.instance
        .collection('/shopExt/${shop.id}/products')
        .where('category1', isEqualTo: 'Gift Vouchers')
        .snapshots()
        .map<List<DocumentSnapshot>>((snapshot) => snapshot.docs)
        .map<List<Voucher>>((docs) =>
            docs.map((doc) => Voucher.fromFirebase(shop, doc.data())).toList());
  }
}
