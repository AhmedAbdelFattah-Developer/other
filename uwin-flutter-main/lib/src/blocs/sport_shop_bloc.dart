import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uwin_flutter/src/models/shop_ext.dart';

class SportShopBloc {
  Stream<List<TabData>> getTabsData(String shopId) => FirebaseFirestore.instance
      .collection('shopExt')
      .doc(shopId)
      .snapshots()
      .map((snap) => ShopExt.fromMap(snap.data()))
      .map((shopExt) => shopExt.tabs);

  void dispose() {}
}
