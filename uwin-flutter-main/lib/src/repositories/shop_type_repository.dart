import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uwin_flutter/src/models/shop_type.dart';

class ShopTypeRepository {
  final CollectionReference collection;

  ShopTypeRepository(this.collection);

  Stream<List<ShopType>> fetchAll() => this
      .collection
      .where('publishedOnWin', isEqualTo: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => ShopType.fromMap(doc.data())).toList()
            ..sort((a, b) => a.position.compareTo(b.position)));
}
