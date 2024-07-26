import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:http/http.dart' as http;

var _collectionName = 'userGiftVouchers';
var _subcollectionName = 'giftVouchers';

class GiftVoucherRepository {
  Stream<List<GiftVoucher>> fetchAllValid(String uid) {
    return FirebaseFirestore.instance
        .collection('$_collectionName/$uid/$_subcollectionName')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => GiftVoucher.fromMap(doc.data()))
              .where((gv) => gv.isValid())
              .toList(),
        );
  }

  Stream<List<GiftVoucher>> fetchAllToBuy() {
    return FirebaseFirestore.instance
        .collectionGroup('products')
        .where('category1', isEqualTo: 'Gift Vouchers')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => GiftVoucher.fromProductMap(doc.data()),
              )
              .toList(),
        );
  }

  Stream<List<GiftVoucher>> fetchAllValidByShop(String uid, String shopId) {
    return FirebaseFirestore.instance
        .collection('$_collectionName/$uid/$_subcollectionName')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => GiftVoucher.fromMap(doc.data()))
              .where((gv) => gv.isValid())
              .toList(),
        );
  }

  Stream<GiftVoucher> fetchValid(String token, String uid, String id) {
    return FirebaseFirestore.instance
        .doc('$_collectionName/$uid/$_subcollectionName/$id')
        .snapshots()
        .map((snap) {
      if (!snap.exists) {
        throw PlatformException(
          code: 'not_found',
          message: 'This gift voucher does not exist',
        );
      }

      final gv = GiftVoucher.fromMap(snap.data());
      if (!gv.isValid()) {
        throw PlatformException(
          code: 'invalid',
          message: 'This gift voucher is not valid',
        );
      }

      return gv;
    });
  }

  Stream<GiftVoucher> fetchFromSalesOrder(String uid, String salesOrderId) {
    return FirebaseFirestore.instance
        .collection('$_collectionName/$uid/$_subcollectionName')
        .where('shopSalesOrderId', isEqualTo: salesOrderId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => GiftVoucher.fromMap(doc.data())).toList(),
        )
        .map((gvList) {
      if (gvList.length == 0) {
        throw PlatformException(
          code: 'not_found',
          message:
              'Could not found gift voucher for order ID $salesOrderId and uid $uid',
        );
      }

      final gv = gvList.first;
      if (!gv.isValid()) {
        throw PlatformException(
          code: 'invalid',
          message: 'This gift voucher is not valid',
        );
      }

      return gv;
    });
  }

  send(String token, String uid, String giftVoucherId, String email) async {
    final url =
        'https://us-central1-uwin-201010.cloudfunctions.net/userApi/v1/users/$uid/gift-vouchers/$giftVoucherId/send';

    final client = new http.Client();
    try {
      var res = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(
          {
            'email': email,
          },
        ),
      );

      if (res.statusCode != 204) {
        print('[gift_voucher_repository] ${res.body}');
        throw PlatformException(
          code: '${res.statusCode}',
          message: 'Could not send gift voucher',
        );
      }
    } finally {
      client.close();
    }
  }
}
