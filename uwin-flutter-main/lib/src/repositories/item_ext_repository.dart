import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uwin_flutter/src/models/item_ext.dart';

class ItemExtRepository {
  Future<List<ItemExt>> fetchByShopId(String shopId) {
    return FirebaseFirestore.instance
        .collection('shopExt')
        .doc(shopId)
        .collection('products')
        .get()
        .then(
          (snaps) => snaps.docs
              .map(
                (doc) => ItemExt.fromMap(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Stream<List<ItemExt>> fetchByShopIdStream(String shopId) {
    return FirebaseFirestore.instance
        .collection('shopExt')
        .doc(shopId)
        .collection('products')
        .snapshots()
        .map<List<ItemExt>>(
          (querySnap) => querySnap.docs
              .map(
                (doc) => ItemExt.fromMap(doc.data()),
              )
              .toList(),
        );
  }
}
